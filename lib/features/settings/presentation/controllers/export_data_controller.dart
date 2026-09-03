import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class ExportDataController extends GetxController {
  final isLoading = false.obs;
  final isExporting = false.obs;
  final totalSessions = 0.obs;
  final totalFocusTime = ''.obs;
  final dateRangeText = ''.obs;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final response = await AppApi.instance.sendRequest.get(
        AppApiUrl.instance.sessionsStatus,
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        final data = response.data["data"];

        totalSessions.value = data['totalSessions'] ?? 0;
        totalFocusTime.value = data['totalFocusTime']?['formatted'] ?? '';

        final start = DateTime.tryParse(data['dateRange']?['startDate'] ?? '');
        final end = DateTime.tryParse(data['dateRange']?['endDate'] ?? '');
        if (start != null && end != null) {
          dateRangeText.value = '${_formatDate(start)} – ${_formatDate(end)}';
        }
      } else {
        CustomSnackbar.show(
          title: 'Load Failed',
          message: 'Could not sync focus summary from server.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Failed to load stats. Check your internet.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportCsv() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final response = await AppApi.instance.sendRequest.get(
        AppApiUrl.instance.exportCsv,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode == 200 && response.data is String) {
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/focus_history_${DateTime.now().millisecondsSinceEpoch}.csv',
        );
        await file.writeAsString(response.data as String);

        CustomSnackbar.show(
          title: 'Export Ready',
          message: 'Your focus history is being prepared for sharing.',
        );
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await Share.shareXFiles([XFile(file.path)], text: 'My focus history export');
      } else {
        CustomSnackbar.show(
          title: 'Export Error',
          message: 'Failed to generate CSV data. Try again.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Network Error',
        message: 'Something went wrong while exporting data.',
        isError: true,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
