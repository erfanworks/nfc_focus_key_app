import 'dart:io';
import 'dart:math';
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
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to load export summary',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportCsv() async {
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

        await Share.shareXFiles([XFile(file.path)], text: 'My focus history export');

        CustomSnackbar.show(
          title: 'Export',
          message: 'CSV file exported successfully.',
        );
      } else {
        CustomSnackbar.show(
          title: 'Error',
          message: 'Failed to export CSV',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Something went wrong while exporting',
        isError: true,
      );
    } finally {
      isExporting.value = false;
    }
  }
}