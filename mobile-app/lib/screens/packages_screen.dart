import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_event_screen.dart';
import 'home_screen.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  // Weather Agent state simulation
  String _selectedCity = 'Nuwara Eliya';
  final List<String> _cities = ['Nuwara Eliya', 'Kandy', 'Colombo', 'Galle', 'Bentota', 'Negombo'];

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  String _seasonName = 'South-West Monsoon Season';
  int _rainProbability = 82;
  String _weatherCondition = 'Hill Country Monsoon Showers & Mist';
  String _riskLevel = 'High';
  bool _marqueeRecommended = true;

  @override
  void initState() {
    super.initState();
    _evaluateWeatherRisk(_selectedCity, _selectedDate);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _evaluateWeatherRisk(_selectedCity, picked);
    }
  }

  void _evaluateWeatherRisk(String city, DateTime date) {
    setState(() {
      _selectedCity = city;
      _selectedDate = date;

      final month = date.month;
      final day = date.day;
      final cLower = city.toLowerCase();

      bool isHill = cLower.contains('nuwara') || cLower.contains('kandy');
      bool isCoast = cLower.contains('galle') || cLower.contains('bentota');

      int baseProb = 20;
      String season;

      if (month >= 5 && month <= 9) {
        season = 'South-West Monsoon Season';
        if (isHill) {
          baseProb = 80;
          _weatherCondition = 'South-West Monsoon Showers & Heavy Mist';
        } else if (isCoast) {
          baseProb = 70;
          _weatherCondition = 'Coastal Monsoon Thunderstorms & Gusts';
        } else {
          baseProb = 55;
          _weatherCondition = 'Overcast Skies with Intermittent Showers';
        }
      } else if (month >= 10 && month <= 12) {
        season = 'North-East Monsoon & 2nd Inter-Monsoon';
        if (isHill) {
          baseProb = 75;
          _weatherCondition = 'North-East Monsoon Showers';
        } else {
          baseProb = 62;
          _weatherCondition = 'Afternoon Tropical Thunderstorms';
        }
      } else if (month >= 1 && month <= 3) {
        season = 'Dry Peak Wedding Season';
        if (isHill) {
          baseProb = 30;
          _weatherCondition = 'Crisp Mountain Breeze with Clear Skies';
        } else {
          baseProb = 18;
          _weatherCondition = 'Clear Sunny Skies & Pleasant Tropical Weather';
        }
      } else {
        season = '1st Inter-Monsoon Thunderstorm Season';
        baseProb = 50;
        _weatherCondition = 'Humid with Late Afternoon Thunderstorms';
      }

      int variance = ((day * 7 + month * 13) % 15) - 6;
      _rainProbability = (baseProb + variance).clamp(10, 95);
      _seasonName = season;

      if (_rainProbability >= 60) {
        _riskLevel = 'High';
        _marqueeRecommended = true;
      } else if (_rainProbability >= 35) {
        _riskLevel = 'Moderate';
        _marqueeRecommended = false;
      } else {
        _riskLevel = 'Low';
        _marqueeRecommended = false;
      }
    });
  }

  final List<Map<String, dynamic>> _cateringPackages = [
    {
      'title': 'International Hotel Buffet',
      'price': 'Rs. 5,200',
      'unit': '/guest',
      'tag': 'MOST POPULAR',
      'tagColor': Color(0xFF2563EB),
      'icon': Icons.restaurant_rounded,
      'description': 'A 5-star international spread with multiple cuisine stations.',
      'items': [
        'Welcome Mocktails & Chilled Fresh Juice Counter',
        '3 Appetizers & Gourmet Salad Bar',
        '2 Rice Varieties (Basmati Steamed & Fried Rice)',
        '3 Meat/Seafood Curries (Chicken, Fish & Prawns)',
        'Deluxe Dessert Counter (Watalappan, Pudding, Fruit)',
      ],
      'idealFor': 'Weddings, Corporate Galas, Anniversaries'
    },
    {
      'title': 'Outdoor Live BBQ Grill Feast',
      'price': 'Rs. 6,500',
      'unit': '/guest',
      'tag': 'PREMIUM LIVE ACTION',
      'tagColor': Color(0xFFD97706),
      'icon': Icons.outdoor_grill_rounded,
      'description': 'Live chef station on outdoor grounds with smoky marinades.',
      'items': [
        'Live Grilled Chicken, Jumbo Prawns & Sausages',
        'Garlic Butter Baguettes & Corn on the Cob',
        'Coleslaw, Potato Salad & German Mustard',
        'Live Kottu & Mini Burger Midnight Station',
        'Sizzling Brownie with Vanilla Bean Ice Cream',
      ],
      'idealFor': 'Lawn Weddings, Birthday Bashes, Cocktail Parties'
    },
    {
      'title': 'Sri Lankan Heritage Traditional Buffet',
      'price': 'Rs. 4,500',
      'unit': '/guest',
      'tag': 'AUTHENTIC CEYLON',
      'tagColor': Color(0xFF059669),
      'icon': Icons.rice_bowl_rounded,
      'description': 'Traditional clay-pot village buffet rich in authentic spices.',
      'items': [
        'Fragrant Ghee Rice & Red Rice',
        'Negombo Black Pork Curry & Devilled Chicken',
        'Cashew & Green Pea Curry with Crispy Papadam',
        'Coconut Sambol, Polos Curry & Gotukola Mallum',
        'Curd & Kithul Treacle with Warm Kavum Bar',
      ],
      'idealFor': 'Homecomings, Family Reunions, Traditional Events'
    },
    {
      'title': 'High Tea Canapé & Snack Platter',
      'price': 'Rs. 3,500',
      'unit': '/guest',
      'tag': 'AFTERNOON RECEPTION',
      'tagColor': Color(0xFF7C3AED),
      'icon': Icons.local_cafe_rounded,
      'description': 'Elegant tea party selection featuring artisanal bites.',
      'items': [
        'Artisanal Ceylon Tea & Brewed Espresso Lounge',
        'Smoked Salmon & Cucumber Finger Sandwiches',
        'Mini Chicken Vol-au-Vents & Crispy Vegetable Spring Rolls',
        'Fresh Fruit Tartlets & French Macarons',
        'Warm Scones with Clotted Cream & Strawberry Jam',
      ],
      'idealFor': 'High Tea Sessions, Engagements, Bridal Showers'
    },
  ];

  final List<Map<String, dynamic>> _serviceAddons = [
    {
      'category': 'Sounds & Lighting',
      'name': 'Concert Line-Array & Digital Lighting Rig',
      'price': 'Rs. 150,000 - 250,000',
      'icon': Icons.speaker_group_rounded,
      'detail': 'Line-array audio, wireless vocal mics, moving heads, truss lighting.'
    },
    {
      'category': 'Thematic Decor',
      'name': 'Royal Fresh Flower Stage & Ceiling Drapes',
      'price': 'Rs. 100,000 - 200,000',
      'icon': Icons.local_florist_rounded,
      'detail': 'Custom backdrop, fresh floral arrangements, walkway pedestals.'
    },
    {
      'category': 'Cinematography',
      'name': '4K Cinematic Video & Storybook Album',
      'price': 'Rs. 120,000 - 250,000',
      'icon': Icons.videocam_rounded,
      'detail': '2 Senior Photographers, 1 Drone Pilot, 4K highlights reel.'
    },
    {
      'category': 'Luxury Transport',
      'name': 'Mercedes-Benz S-Class Bridal Chauffeur Sedan',
      'price': 'Rs. 65,000 - 95,000',
      'icon': Icons.directions_car_rounded,
      'detail': 'Decorated 4-seater executive sedan with chauffeur.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leadingWidth: 56,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 8,
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu_rounded, color: Color(0xFF38BDF8), size: 20),
            SizedBox(width: 8),
            Text(
              'Catering & Weather Advisory',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 750;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.12 : 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. AGENTIC AI WEATHER RISK RADAR
                _buildWeatherRadarCard(),
                const SizedBox(height: 24),

                // 2. SECTION HEADER: CATERING PACKAGES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Curated Catering Menus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Curated Packages',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select from standard 5-star hotel banquet catering styles. Quantities dynamically adjust to your guest count.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Catering Package Cards
                ..._cateringPackages.map((pkg) => _buildCateringCard(pkg)),

                const SizedBox(height: 24),

                // 3. SECTION HEADER: SERVICE ADD-ONS
                const Text(
                  'Production & Service Add-ons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enhance your event with sound rigs, cinematic coverage, floral decor, and luxury bridal transport.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Service Add-on Cards
                ..._serviceAddons.map((srv) => _buildServiceAddonCard(srv)),

                const SizedBox(height: 32),

                // 4. ACTION BUTTON: PLAN EVENT
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                    label: const Text(
                      'Book Event with Custom Resources',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- AGENTIC AI WEATHER RADAR WIDGET ---
  Widget _buildWeatherRadarCard() {
    final isHighRisk = _riskLevel == 'High';
    final riskColor = isHighRisk ? const Color(0xFFEF4444) : (_riskLevel == 'Moderate' ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF38BDF8), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather Risk Agent',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Real-time Monsoonal Assessment & Safeguard Tool',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(
                      '$_riskLevel Risk',
                      style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Target Event Date Selection (Spacious, responsive layout with dedicated date row)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Event Date',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    InkWell(
                      onTap: () => _pickDate(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 13, color: Color(0xFF38BDF8)),
                            SizedBox(width: 5),
                            Text(
                              'Change Date',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event_available_rounded, color: Color(0xFF38BDF8), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. City selector chips
          const Text(
            'Select Event Location / City:',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cities.map((city) {
              final isSelected = _selectedCity == city;
              return InkWell(
                onTap: () => _evaluateWeatherRisk(city, _selectedDate),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                    ),
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 3. Weather Metrics Display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedCity,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _seasonName,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weatherCondition,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_rainProbability%',
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Rain Chance',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Safeguard Recommendation Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _marqueeRecommended ? const Color(0xFFEF4444).withOpacity(0.12) : const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _marqueeRecommended ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _marqueeRecommended ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                  color: _marqueeRecommended ? const Color(0xFFF87171) : const Color(0xFF34D399),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _marqueeRecommended
                        ? 'High rain probability ($_rainProbability%) predicted for outdoor grounds in $_selectedCity on ${DateFormat('dd MMM yyyy').format(_selectedDate)} ($_seasonName). Weather Agent auto-injects a Heavy-Duty Waterproof Marquee Tent (Rs. 150,000) safeguard.'
                        : 'Weather conditions in $_selectedCity on ${DateFormat('dd MMM yyyy').format(_selectedDate)} are favorable ($_rainProbability% rain chance). Safe for open-air lawn events; 0 marquee shelter needed.',
                    style: TextStyle(
                      color: _marqueeRecommended ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CATERING PACKAGE CARD ---
  Widget _buildCateringCard(Map<String, dynamic> pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (pkg['tagColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(pkg['icon'] as IconData, color: pkg['tagColor'] as Color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pkg['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (pkg['tagColor'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  pkg['tag'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: pkg['tagColor'] as Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                pkg['price'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pkg['unit'],
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  pkg['description'],
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                const Text(
                  'Included Menu Items:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                ...(pkg['items'] as List<String>).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_outline_rounded, color: Color(0xFF64748B), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ideal for: ${pkg['idealFor']}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SERVICE ADD-ON CARD ---
  Widget _buildServiceAddonCard(Map<String, dynamic> srv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(srv['icon'] as IconData, color: const Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  srv['category'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  srv['name'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  srv['detail'],
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            srv['price'],
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
          ),
        ],
      ),
    );
  }
}
