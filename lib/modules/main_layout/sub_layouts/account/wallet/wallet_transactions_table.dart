import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletTransactionTable extends StatelessWidget {
  const WalletTransactionTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var accountCubit = AccountCubit.get(context);
    var localizationStrings = AppLocalizations.of(context);
    return DataTable(
        columnSpacing: 0,
        dataRowHeight: 80,
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: <DataColumn>[
          DataColumn(
            label: Text(localizationStrings!.id,
                style: mainStyle(14.w, FontWeight.w400,
                    color: mainBackgroundColor)),
          ),
          DataColumn(
            label: Flexible(
              child: Text(localizationStrings.transaction_type,
                  textAlign: TextAlign.center,
                  style: mainStyle(14.w, FontWeight.w400,
                      color: mainBackgroundColor)),
            ),
          ),
          DataColumn(
            label: Text(localizationStrings.credit,
                style: mainStyle(14.w, FontWeight.w400,
                    color: mainBackgroundColor)),
          ),
          DataColumn(
            label: Text(localizationStrings.debit,
                style: mainStyle(14.w, FontWeight.w400,
                    color: mainBackgroundColor)),
          ),
          DataColumn(
            label: Text(localizationStrings.balance,
                style: mainStyle(14.w, FontWeight.w400,
                    color: mainBackgroundColor)),
          ),
          DataColumn(
            label: Text(localizationStrings.date,
                style: mainStyle(14.w, FontWeight.w400,
                    color: mainBackgroundColor)),
          ),
        ],
        rows: List<DataRow>.generate(
            accountCubit.walletTransactions.length,
            (index) => DataRow(
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 0.7,
                        child: Text((index + 1).toString(),
                            style: mainStyle(12.w, FontWeight.w400,
                                color: primaryColor)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 2.2,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: accountCubit
                                    .walletTransactions[index].transactionType
                                    .toString(),
                                style: mainStyle(12.w, FontWeight.w400,
                                    color: primaryColor)),
                            TextSpan(
                                text: '\n' +
                                    localizationStrings.paymentStatus +
                                    accountCubit
                                        .walletTransactions[index].statusPayment
                                        .toString(),
                                style: mainStyle(12.w, FontWeight.w400,
                                    color: Colors.green)),
                          ]),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 1.5,
                        child: Text(
                            accountCubit
                                .walletTransactions[index].creditFormatted
                                .toString(),
                            style: mainStyle(12.w, FontWeight.w400,
                                color: primaryColor)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 1.5,
                        child: Text(
                            accountCubit
                                .walletTransactions[index].debitFormatted
                                .toString(),
                            style: mainStyle(12.w, FontWeight.w400,
                                color: primaryColor)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 1.6,
                        child: Text(
                            accountCubit
                                .walletTransactions[index].balanceFormatted
                                .toString(),
                            style: mainStyle(12.w, FontWeight.w400,
                                color: primaryColor)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 10) * 2.4,
                        child: Text(
                            accountCubit.walletTransactions[index].createdAt
                                .toString(),
                            style: mainStyle(12.w, FontWeight.w400,
                                color: primaryColor)),
                      ),
                    ),
                  ],
                )));
  }
}
