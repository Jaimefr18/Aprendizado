import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'history_screen.dart';
import 'reports_screen.dart';

class EnergyData {
  final double electricalEnergy;
  final DateTime timestamp;

  EnergyData(this.electricalEnergy, this.timestamp);
}

class DashboardStatus {
  final double energyLevel;
  final String levelText;
  final String levelColor;
  final double valueWh;
  final DateTime timestamp;
  final String trend;

  DashboardStatus({
    required this.energyLevel,
    required this.levelText,
    required this.levelColor,
    required this.valueWh,
    required this.timestamp,
    required this.trend,
  });

  factory DashboardStatus.fromJson(Map<String, dynamic> json) {
    return DashboardStatus(
      energyLevel: (json['energy_level'] ?? 0.0).toDouble(),
      levelText: json['level_text'] ?? 'DESCONHECIDO',
      levelColor: json['level_color'] ?? '#FF0000',
      valueWh: (json['value_wh'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      trend: json['trend'] ?? 'stable',
    );
  }
}

class DashboardMetrics {
  final double totalEnergyKwh;
  final int totalSamples;
  final double averageEnergyWh;
  final double lastReadingWh;

  DashboardMetrics({
    required this.totalEnergyKwh,
    required this.totalSamples,
    required this.averageEnergyWh,
    required this.lastReadingWh,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalEnergyKwh: (json['total_energy_kwh'] ?? 0.0).toDouble(),
      totalSamples: (json['total_samples'] ?? 0).toInt(),
      averageEnergyWh: (json['average_energy_wh'] ?? 0.0).toDouble(),
      lastReadingWh: (json['last_reading_wh'] ?? 0.0).toDouble(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  final List<EnergyData> _data = [];
  double _totalEnergy = 0.0;
  int _sampleCount = 0;
  double _averageEnergy = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;
  int _selectedIndex = 0;
  
  bool _isSidebarVisible = false;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  // Variáveis para API
  bool _isLoading = true;
  String _apiStatus = 'Conectando à API...';
  bool _usingRealApi = false;
  String _errorMessage = '';

  // SUA API LOCAL
  final String _apiUrl = 'http://0.0.0.0:3000/dashboard';

  // Status atual
  DashboardStatus _currentStatus = DashboardStatus(
    energyLevel: 0.0,
    levelText: 'CARREGANDO',
    levelColor: '#FF666666',
    valueWh: 0.0,
    timestamp: DateTime.now(),
    trend: 'stable',
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _sidebarAnimation = Tween<double>(
      begin: 0,
      end: 280,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));
    
    _connectToAPI();
  }

  Future<void> _connectToAPI() async {
    try {
      setState(() {
        _isLoading = true;
        _apiStatus = 'Conectando à API...';
        _errorMessage = '';
      });

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _processApiData(jsonData);
        
        setState(() {
          _usingRealApi = true;
          _apiStatus = 'Conectado à API Local';
          _isLoading = false;
        });
        
        // Iniciar atualizações em tempo real
        _startApiPolling();
        
      } else {
        throw Exception('API retornou erro: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback para dados simulados
      setState(() {
        _usingRealApi = false;
        _apiStatus = 'Erro na API - Usando dados simulados';
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _startLiveStream();
    }
  }

  void _startApiPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_isLoading && mounted) {
        try {
          final response = await http.get(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            _processApiData(jsonData);
          }
        } catch (e) {
          print('Erro na atualização da API: $e');
        }
      }
    });
  }

  void _processApiData(Map<String, dynamic> jsonData) {
    final dashboard = jsonData;
    
    setState(() {
      // Processar status atual da API
      if (dashboard['current_status'] != null) {
        _currentStatus = DashboardStatus.fromJson(dashboard['current_status']);
      }

      // Processar live stream da API
      if (dashboard['live_stream'] != null) {
        final liveData = dashboard['live_stream'] as List;
        _data.clear();
        for (var item in liveData) {
          _data.add(EnergyData(
            (item['electrical_energy'] ?? 0.0).toDouble(),
            DateTime.parse(item['timestamp']),
          ));
        }
      }

      // Processar métricas da API
      if (dashboard['metrics'] != null) {
        final metrics = DashboardMetrics.fromJson(dashboard['metrics']);
        _totalEnergy = metrics.totalEnergyKwh;
        _sampleCount = metrics.totalSamples;
        _averageEnergy = metrics.averageEnergyWh;
      }
    });
  }

  void _startLiveStream() {
    // Dados simulados (fallback)
    for (int i = 0; i < 10; i++) {
      _data.add(EnergyData(
        0.02 + _random.nextDouble() * 0.05,
        DateTime.now().subtract(Duration(seconds: 10 - i)),
      ));
    }

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          final newEnergy = 0.02 + _random.nextDouble() * 0.08;
          _data.add(EnergyData(newEnergy, DateTime.now()));
          _totalEnergy += newEnergy;
          _sampleCount++;
          _averageEnergy = _sampleCount > 0 ? (_totalEnergy * 1000) / _sampleCount : 0;
          if (_data.length > 20) _data.removeAt(0);
          
          // Atualizar status com dados simulados
          _currentStatus = DashboardStatus(
            energyLevel: newEnergy,
            levelText: _getEnergyLevelText(newEnergy),
            levelColor: _getEnergyLevelColorHex(newEnergy),
            valueWh: newEnergy * 1000,
            timestamp: DateTime.now(),
            trend: _getRandomTrend(),
          );
        });
      }
    });
  }

  String _getRandomTrend() {
    final trends = ['rising', 'falling', 'stable'];
    return trends[_random.nextInt(trends.length)];
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
      if (_isSidebarVisible) {
        _sidebarController.forward();
      } else {
        _sidebarController.reverse();
      }
    });
  }

  void _closeSidebar() {
    if (_isSidebarVisible) {
      _toggleSidebar();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _sidebarController.dispose();
    super.dispose();
  }

  Color _getEnergyLevelColor(double e) {
    if (e < 0.02) return const Color(0xFFFF4D6D);
    if (e < 0.04) return const Color(0xFFFF9800);
    if (e < 0.06) return const Color(0xFFFFD54F);
    return const Color(0xFF00E6FF);
  }

  String _getEnergyLevelText(double e) {
    if (e < 0.02) return 'CRÍTICA';
    if (e < 0.04) return 'BAIXA';
    if (e < 0.06) return 'MÉDIA';
    return 'ALTA';
  }

  String _getEnergyLevelColorHex(double energy) {
    if (energy < 0.02) return '#FFFF4D6D';
    if (energy < 0.04) return '#FFFF9800';
    if (energy < 0.06) return '#FFFFD54F';
    return '#FF00E6FF';
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'rising': return 'Subindo ↗';
      case 'falling': return 'Descendo ↘';
      case 'stable': return 'Estável →';
      default: return 'Estável →';
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      _closeSidebar();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
    
    _closeSidebar();
    
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ReportsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00E6FF)),
            SizedBox(height: 20),
            Text(
              'Conectando à API...',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              _apiStatus,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'URL: $_apiUrl',
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(0xFFFF4D6D), size: 64),
            SizedBox(height: 20),
            Text(
              'Erro de Conexão',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'URL: $_apiUrl',
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00E6FF),
                foregroundColor: Colors.black,
              ),
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage.isNotEmpty && !_usingRealApi) {
      return _buildErrorScreen();
    }

    final levelColor = _hexToColor(_currentStatus.levelColor);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: IconButton(
                        onPressed: _toggleSidebar,
                        icon: Icon(
                          _isSidebarVisible ? Icons.menu_open : Icons.menu,
                          color: const Color(0xFF00E6FF),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.bolt, color: Color(0xFFFFD54F), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'PAWAKINI',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                            color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: GestureDetector(
                  onTap: _closeSidebar,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status da conexão
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _usingRealApi 
                                ? Color(0xFF00E6FF).withOpacity(0.1)
                                : Color(0xFFFFD54F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F)
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                                color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _apiStatus,
                                      style: TextStyle(
                                        color: Colors.white70, 
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_errorMessage.isNotEmpty)
                                      Text(
                                        _errorMessage,
                                        style: TextStyle(
                                          color: Colors.white54, 
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _usingRealApi ? 'API Local' : 'Simulado',
                                style: TextStyle(
                                  color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        _buildStatusCard(levelColor, _currentStatus),
                        const SizedBox(height: 24),
                        _buildLiveChart(levelColor),
                        const SizedBox(height: 24),
                        _buildMetricsGrid(levelColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isSidebarVisible)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              return Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(-(280 - _sidebarAnimation.value), 0),
                  child: _buildSidebar(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(right: BorderSide(color: Colors.white12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _closeSidebar,
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF00E6FF),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E6FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00E6FF).withOpacity(0.3)
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Color(0xFF00E6FF),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PAWAKINI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Energy Management',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildNavItem(Icons.dashboard, 'Dashboard', 0, _selectedIndex == 0),
                  _buildNavItem(Icons.history, 'Histórico', 1, _selectedIndex == 1),
                  _buildNavItem(Icons.analytics, 'Relatórios', 2, _selectedIndex == 2),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                        color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _usingRealApi ? 'API Conectada' : 'Modo Simulado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _usingRealApi ? 0.9 : 0.6,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? const Color(0xFF00E6FF).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF00E6FF) : Colors.white54,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00E6FF) : Colors.white54,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) 
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E6FF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Color color, DashboardStatus status) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "STATUS ATUAL",
                      style: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status.levelText,
                      style: TextStyle(
                        color: color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${status.valueWh.toStringAsFixed(1)} Wh",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tendência: ${_getTrendText(status.trend)}",
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.6 + _pulseController.value * 0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_pulseController.value * 0.4),
                      blurRadius: 25,
                      spreadRadius: _pulseController.value * 4,
                    ),
                  ],
                ),
                child: Icon(Icons.bolt, color: color, size: 45),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveChart(Color color) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FLUXO DE ENERGIA - ${_usingRealApi ? 'API' : 'SIMULAÇÃO'}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  "${_data.length} amostras",
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: EnergyChartPainter(data: _data, color: color),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Color color) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _metricCard(
          'Energia Total', 
          '${_totalEnergy.toStringAsFixed(3)} kWh',
          Icons.energy_savings_leaf, 
          const Color(0xFFFFD54F),
          _usingRealApi ? 'API' : 'Simulado'
        ),
        _metricCard(
          'Amostras', 
          '$_sampleCount',
          Icons.insights, 
          const Color(0xFFE0E0E0),
          'Total coletadas'
        ),
        _metricCard(
          'Média por Amostra',
          '${_averageEnergy.toStringAsFixed(1)} Wh',
          Icons.auto_graph,
          const Color(0xFFFF9800),
          'Valor médio'
        ),
        _metricCard(
          'Última Leitura',
          '${_currentStatus.valueWh.toStringAsFixed(1)} Wh',
          Icons.speed,
          const Color(0xFFFF4D6D),
          'Atual'
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(
                _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12, 
                  color: Color(0xFFBDBDBD)
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnergyChartPainter extends CustomPainter {
  final List<EnergyData> data;
  final Color color;
  EnergyChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      // Desenhar estado vazio
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Aguardando dados...',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ));
      return;
    }

    final maxEnergy = data.map((e) => e.electricalEnergy).reduce((a, b) => a > b ? a : b) * 1.2;
    final minEnergy = 0.0;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final pathLine = Path();
    final pathArea = Path();

    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final normalized = (data[i].electricalEnergy - minEnergy) / (maxEnergy - minEnergy);
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        pathLine.moveTo(x, y);
        pathArea.moveTo(x, size.height);
        pathArea.lineTo(x, y);
      } else {
        pathLine.lineTo(x, y);
        pathArea.lineTo(x, y);
      }
      final pointPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    pathArea.lineTo(size.width, size.height);
    pathArea.close();
    canvas.drawPath(pathArea, fillPaint);
    canvas.drawPath(pathLine, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}