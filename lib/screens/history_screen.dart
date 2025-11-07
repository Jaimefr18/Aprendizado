import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'reports_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> 
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _historyData = [];
  int _selectedIndex = 1;
  bool _isSidebarVisible = false;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  // Variáveis para API
  bool _isLoading = true;
  String _apiStatus = 'Carregando...';
  String _errorMessage = '';
  bool _usingRealApi = false;
  final String _apiUrl = 'http://0.0.0.0:3000/history';

  @override
  void initState() {
    super.initState();
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

    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
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
        final List<dynamic> jsonData = jsonDecode(response.body);
        _processApiData(jsonData);
        
        setState(() {
          _usingRealApi = true;
          _apiStatus = 'Dados carregados da API';
          _isLoading = false;
        });
        
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
      _loadMockData();
    }
  }

  void _processApiData(List<dynamic> jsonData) {
    setState(() {
      _historyData = jsonData.map((item) {
        return {
          'date': item['date'] ?? 'Data não disponível',
          'totalEnergy': (item['total_energy'] ?? 0.0).toDouble(),
          'peakPower': (item['peak_power'] ?? 0.0).toDouble(),
          'efficiency': (item['efficiency'] ?? 0.0).toDouble(),
          'status': item['status'] ?? 'medium'
        };
      }).toList();
    });
  }

  void _loadMockData() {
    // Dados simulados (fallback)
    setState(() {
      _historyData = [
        {
          'date': '2024-01-15',
          'totalEnergy': 12.45,
          'peakPower': 215.6,
          'efficiency': 0.82,
          'status': 'high'
        },
        {
          'date': '2024-01-14',
          'totalEnergy': 10.23,
          'peakPower': 198.3,
          'efficiency': 0.78,
          'status': 'medium'
        },
        {
          'date': '2024-01-13',
          'totalEnergy': 8.67,
          'peakPower': 176.8,
          'efficiency': 0.75,
          'status': 'medium'
        },
        {
          'date': '2024-01-12',
          'totalEnergy': 15.89,
          'peakPower': 245.2,
          'efficiency': 0.85,
          'status': 'high'
        },
        {
          'date': '2024-01-11',
          'totalEnergy': 6.34,
          'peakPower': 154.7,
          'efficiency': 0.68,
          'status': 'low'
        },
        {
          'date': '2024-01-10',
          'totalEnergy': 9.78,
          'peakPower': 187.4,
          'efficiency': 0.76,
          'status': 'medium'
        },
        {
          'date': '2024-01-09',
          'totalEnergy': 11.23,
          'peakPower': 203.1,
          'efficiency': 0.79,
          'status': 'high'
        },
      ];
    });
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'high':
        return const Color(0xFF00E6FF);
      case 'medium':
        return const Color(0xFFFFD54F);
      case 'low':
        return const Color(0xFFFF4D6D);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MÉDIA';
      case 'low':
        return 'BAIXA';
      default:
        return 'DESCONHECIDO';
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
    
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
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
              'Carregando histórico...',
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
              'Erro ao Carregar',
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
              onPressed: _loadHistoryData,
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

    if (_errorMessage.isNotEmpty && _historyData.isEmpty) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Conteúdo Principal
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    // Botão para mostrar/esconder sidebar
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
                          Icon(Icons.history, color: Color(0xFF00E6FF), size: 28),
                          SizedBox(width: 12),
                          Text(
                            'HISTÓRICO',
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
              
              // Conteúdo rolável
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
                                '${_historyData.length} registos',
                                style: TextStyle(
                                  color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Filtros
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: '7_days',
                                      items: [
                                        DropdownMenuItem(
                                          value: '7_days', 
                                          child: Text('Últimos 7 dias', style: TextStyle(color: Colors.white))
                                        ),
                                        DropdownMenuItem(
                                          value: '30_days', 
                                          child: Text('Últimos 30 dias', style: TextStyle(color: Colors.white))
                                        ),
                                        DropdownMenuItem(
                                          value: '90_days', 
                                          child: Text('Últimos 90 dias', style: TextStyle(color: Colors.white))
                                        ),
                                      ],
                                      onChanged: (value) {
                                        // Aqui você pode implementar a filtragem por período
                                      },
                                      dropdownColor: const Color(0xFF1A1A1A),
                                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E6FF)),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: _loadHistoryData,
                                  icon: const Icon(Icons.refresh, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Lista de Histórico
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registos de Energia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Total: ${_historyData.length}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_historyData.isEmpty)
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.history, color: Colors.white54, size: 64),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum dado histórico encontrado',
                                  style: TextStyle(color: Colors.white54, fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Verifique sua conexão com a API',
                                  style: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._historyData.map((data) => _buildHistoryItem(data)).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Overlay escuro quando sidebar está aberta
          if (_isSidebarVisible)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Sidebar animada
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
          // Logo Section com botão de fechar
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
          
          // Navigation Items
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
          
          // Footer
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

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    final statusColor = _getStatusColor(data['status']);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Icon(
            Icons.bolt,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              data['date'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(data['status']),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMetricItem('Energia', '${data['totalEnergy']} kWh', Icons.energy_savings_leaf),
                const SizedBox(width: 16),
                _buildMetricItem('Pico', '${data['peakPower']}W', Icons.speed),
                const SizedBox(width: 16),
                _buildMetricItem('Eficiência', '${(data['efficiency'] * 100).toInt()}%', Icons.auto_graph),
              ],
            ),
          ],
        ),
        trailing: Icon(
          _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
          color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00E6FF), size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}