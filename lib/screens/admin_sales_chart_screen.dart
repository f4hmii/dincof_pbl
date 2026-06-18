import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../helpers/currency_helper.dart';
import '../theme/colors.dart';

class AdminSalesChartScreen extends StatelessWidget {
  const AdminSalesChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Laporan Penjualan & Grafik'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final orders = provider.orders;

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Transaksi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Grafik akan muncul di sini setelah ada pesanan yang diselesaikan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          // Hitung Statistik
          double totalRevenue = 0;
          int totalTransactions = orders.length;
          Map<String, double> coffeeSalesCount = {};
          Map<String, double> dailySales = {};

          // Urutkan pesanan dari yang paling lama ke yang terbaru untuk grafik kronologis
          final sortedOrders = List.from(orders).reversed.toList();

          for (var order in sortedOrders) {
            totalRevenue += order.total;
            
            // Statistik Kopi Terlaris
            for (var item in order.items) {
              final name = item.coffee.name;
              coffeeSalesCount[name] = (coffeeSalesCount[name] ?? 0) + item.quantity;
            }

            // Statistik Penjualan Harian (format tanggal dd/MM)
            final dateKey = DateFormat('dd/MM').format(order.date);
            dailySales[dateKey] = (dailySales[dateKey] ?? 0) + order.total;
          }

          // Dapatkan Kopi Terlaris
          String bestSeller = 'Belum ada';
          double bestQty = 0;
          coffeeSalesCount.forEach((key, value) {
            if (value > bestQty) {
              bestQty = value;
              bestSeller = key;
            }
          });

          // Siapkan data grafik (maksimal 7 entri terakhir)
          List<String> dates = dailySales.keys.toList();
          if (dates.length > 7) {
            dates = dates.sublist(dates.length - 7);
          }

          List<FlSpot> spots = [];
          for (int i = 0; i < dates.length; i++) {
            spots.add(FlSpot(i.toDouble(), dailySales[dates[i]] ?? 0.0));
          }

          // Jika entri cuma 1, tambahkan spot bayangan di awal agar bisa ditarik garisnya
          if (spots.length == 1) {
            spots = [FlSpot(0, 0), FlSpot(1, spots[0].y)];
            dates = ['-', dates[0]];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu Ringkasan
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Pendapatan',
                        value: formatRupiah(totalRevenue),
                        icon: Icons.monetization_on,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Transaksi',
                        value: '$totalTransactions Pesanan',
                        icon: Icons.receipt,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Terlaris',
                        value: bestSeller,
                        icon: Icons.coffee,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Penjelasan Grafik
                Text(
                  'Grafik Pendapatan Harian',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menampilkan grafik tren omset harian Anda dalam 7 transaksi hari terakhir.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Area Grafik
                Container(
                  height: 240,
                  padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Theme.of(context).dividerColor,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              // Tampilkan label harga ringkas, misal 50k
                              if (value == 0) return const SizedBox.shrink();
                              if (value >= 1000000) {
                                return Text(
                                  '${(value / 1000000).toStringAsFixed(1)}M',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                );
                              }
                              if (value >= 1000) {
                                return Text(
                                  '${(value / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                );
                              }
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < dates.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    dates[index],
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minX: 0,
                      maxX: (dates.length - 1).toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
