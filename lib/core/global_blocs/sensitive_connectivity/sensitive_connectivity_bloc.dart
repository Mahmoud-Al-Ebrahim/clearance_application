import 'package:bloc/bloc.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/main_functions/main_funcs.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
part 'sensitive_connectivity_event.dart';
part 'sensitive_connectivity_state.dart';

class SensitiveConnectivityBloc extends Bloc<SensitiveConnectivityEvent, SensitiveConnectivityState> {
  SensitiveConnectivityBloc() : super(ConnectivityOfflineState()) {
    on<ChangeConnectivityEvent>(_onCheckConnectivity);
  }

  void _onCheckConnectivity(
    ChangeConnectivityEvent event,
    Emitter<SensitiveConnectivityState> emit,
  ) async {
    if (event.connectivityResult == ConnectivityResult.mobile) {
      showMessage('Internet connected',foreGroundColor: Colors.green,timeShowing: Toast.LENGTH_SHORT);
      emit(ConnectivityCellularState());
    } else if (event.connectivityResult == ConnectivityResult.wifi) {
      showMessage('Internet connected',foreGroundColor: Colors.green,timeShowing: Toast.LENGTH_SHORT);
      emit(ConnectivityWifiState());
    } else if(event.connectivityResult == ConnectivityResult.none){
      showMessage('No Internet connection.',timeShowing: Toast.LENGTH_LONG);
      emit(ConnectivityOfflineState());
    }
  }
}
