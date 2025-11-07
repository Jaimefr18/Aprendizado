import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'history_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> 
    with TickerProviderStateMixin {
  String _selectedPeriod = 'weekly';
  int _selectedIndex = 2;
  bool _isSidebarVisible = false;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  // Variáveis para API
  bool _isLoading = true;
  String _apiStatus = 'Carregando...';
  String _errorMessage = '';
  bool _usingRealApi = false;
  final String _apiBaseUrl = 'http://0.0.0.0:3000/reports';

  // Dados da API
  Map<String, dynamic> _reportsData = {};
  List<dynamic> _statistics = [];
  List<dynamic> _insights = [];
  List<dynamic> _trendData = [];

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

    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      setState(() {
        _isLoading = true;
        _apiStatus = 'Conectando à API...';
        _errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/$_selectedPeriod'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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

  void _processApiData(Map<String, dynamic> jsonData) {
    setState(() {
      _reportsData = jsonData;
      _statistics = jsonData['statistics'] ?? [];
      _insights = jsonData['insights'] ?? [];
      _trendData = jsonData['trend_data'] ?? [12.5, 15.2, 14.8, 16.7, 18.3, 15.9, 17.2];
    });
  }

  void _loadMockData() {
    // Dados simulados (fallback)
    setState(() {
      _statistics = [
        {
          'title': 'Energia Total',
          'value': '156.8 kWh',
          'icon': 'energy_savings_leaf',
          'color': '#FF00E6FF',
          'subtitle': '+12% vs período anterior',
        },
        {
          'title': 'Eficiência Média',
          'value': '78.4%',
          'icon': 'auto_graph',
          'color': '#FFFFD54F',
          'subtitle': '+3.2% vs período anterior',
        },
        {
          'title': 'Pico de Potência',
          'value': '245.6 W',
          'icon': 'speed',
          'color': '#FF00E6FF',
          'subtitle': 'Novo recorde!',
        },
        {
          'title': 'Tempo de Operação',
          'value': '142h 30m',
          'icon': 'timer',
          'color': '#FFFFD54F',
          'subtitle': '94% disponibilidade',
        },
      ];

      _insights = [
        {
          'title': 'Melhor Performance',
          'description': 'Sexta-feira entre 14:00-16:00',
          'icon': 'arrow_upward',
          'color': '#FF00E6FF',
        },
        {
          'title': 'Oportunidade de Melhoria',
          'description': 'Aumentar eficiência nos fins de semana',
          'icon': 'trending_up',
          'color': '#FFFFD54F',
        },
        {
          'title': 'Manutenção Preventiva',
          'description': 'Verificar sistema em 15 dias',
          'icon': 'build',
          'color': '#FFFFD54F',
        },
      ];

      _trendData = [12.5, 15.2, 14.8, 16.7, 18.3, 15.9, 17.2];
    });
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'energy_savings_leaf':
        return Icons.energy_savings_leaf;
      case 'auto_graph':
        return Icons.auto_graph;
      case 'speed':
        return Icons.speed;
      case 'timer':
        return Icons.timer;
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'trending_up':
        return Icons.trending_up;
      case 'build':
        return Icons.build;
      default:
        return Icons.analytics;
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return 'Últimas 24 horas';
      case 'weekly':
        return 'Últimas 4 semanas';
      case 'monthly':
        return 'Últimos 12 meses';
      case 'yearly':
        return 'Últimos 5 anos';
      default:
        return 'Período selecionado';
    }
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
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(),
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
              'Carregando relatórios...',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              _apiStatus,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'Período: $_selectedPeriod',
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
              'URL: $_apiBaseUrl/$_selectedPeriod',
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadReportsData,
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

    if (_errorMessage.isNotEmpty && _statistics.isEmpty) {
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
                    Expanded(
                      child: Row(
                        children: const [
                          Icon(Icons.analytics, color: Color(0xFF00E6FF), size: 24),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'RELATÓRIOS',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Color(0xFF00E6FF)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.print, color: Color(0xFF00E6FF)),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
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
                                _usingRealApi ? 'API' : 'Simulado',
                                style: TextStyle(
                                  color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Período Selector
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPeriodButton('Diário', 'daily'),
                              _buildPeriodButton('Semanal', 'weekly'),
                              _buildPeriodButton('Mensal', 'monthly'),
                              _buildPeriodButton('Anual', 'yearly'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Estatísticas Principais
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: _statistics.map((stat) => _buildStatCard(
                            stat['title'] ?? 'Título',
                            stat['value'] ?? '0',
                            _getIconFromString(stat['icon'] ?? 'analytics'),
                            _getColorFromHex(stat['color'] ?? '#FF00E6FF'),
                            stat['subtitle'] ?? '',
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Gráfico de Tendência
                        _buildTrendChart(),
                        const SizedBox(height: 24),
                        
                        // Insights
                        _buildInsightsCard(),
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

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
          _loadReportsData(); // Recarrega dados quando muda o período
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E6FF) : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                color: color.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tendência de Produção',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _usingRealApi ? Icons.cloud_done : Icons.cloud_off,
                color: _usingRealApi ? Color(0xFF00E6FF) : Color(0xFFFFD54F),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPeriodText(_selectedPeriod),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: CustomPaint(
              painter: _TrendChartPainter(data: _trendData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFFFFD54F)),
              SizedBox(width: 8),
              Text(
                'INSIGHTS - ${_usingRealApi ? 'API' : 'SIMULADO'}',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._insights.map((insight) => _buildInsightItem(
            insight['title'] ?? 'Título',
            insight['description'] ?? 'Descrição',
            _getIconFromString(insight['icon'] ?? 'lightbulb'),
            _getColorFromHex(insight['color'] ?? '#FFFFD54F'),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<dynamic> data;

  _TrendChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // Converte dados para double
    final List<double> numericData = data.map((e) => (e is num ? e.toDouble() : 0.0)).toList();
    
    if (numericData.isEmpty) {
      // Desenhar estado vazio
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Sem dados de tendência',
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

    final maxValue = numericData.reduce((a, b) => a > b ? a : b) * 1.1;
    
    final paintLine = Paint()
      ..color = const Color(0xFF00E6FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF00E6FF).withOpacity(0.3), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final pathLine = Path();
    final pathArea = Path();
    
    for (int i = 0; i < numericData.length; i++) {
      final x = size.width * i / (numericData.length - 1);
      final y = size.height - (numericData[i] / maxValue) * size.height;
      
      if (i == 0) {
        pathLine.moveTo(x, y);
        pathArea.moveTo(x, size.height);
        pathArea.lineTo(x, y);
      } else {
        pathLine.lineTo(x, y);
        pathArea.lineTo(x, y);
      }
    }
    
    pathArea.lineTo(size.width, size.height);
    pathArea.close();
    
    canvas.drawPath(pathArea, paintFill);
    canvas.drawPath(pathLine, paintLine);
    
    // Pontos
    final paintPoints = Paint()..color = const Color(0xFF00E6FF);
    for (int i = 0; i < numericData.length; i++) {
      final x = size.width * i / (numericData.length - 1);
      final y = size.height - (numericData[i] / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 4, paintPoints);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}