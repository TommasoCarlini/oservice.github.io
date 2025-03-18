import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/payment.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/enums/months.dart';
import 'package:oservice/widgets/dropdown/monthsDropdown.dart';

class PaymentsScreen extends StatefulWidget {
  final Function changeTab;
  final TabController menu;

  const PaymentsScreen({
    super.key,
    required this.changeTab,
    required this.menu,
  });

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late FirebaseHelper firebaseHelper;
  late List<Payment> payments = [];
  late List<Collaborator> collaborators = [];
  bool isLoading = true;
  bool yearlyPayments = false;
  bool groupPayments = false;

  Month selectedMonth = Month.getCurrentMonth();

  // Mappa che raggruppa i pagamenti per nome collaboratore
  Map<String, int> paymentsGrouped = {};

  @override
  void initState() {
    super.initState();
    firebaseHelper = FirebaseHelper.initialize();
    _loadData();
  }

  int evaluateYear() {
    if (selectedMonth.number > Month.getCurrentMonth().number) {
      return DateTime.now().year - 1;
    } else {
      return DateTime.now().year;
    }
  }

  Future<void> _loadData() async {
    await _loadPayments();
    _updatePayments(); // Aggiorna la mappa dopo aver caricato i pagamenti
    await _loadCollaborators();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadPayments() async {
    try {
      List<Payment> p = await FirebaseHelper.retrievePayments(
          evaluateYear(), selectedMonth.number);
      setState(() {
        payments = p.toList();
        payments.sort((a, b) => a.date.compareTo(b.date));
      });
    } catch (e) {
      print("Errore durante il caricamento dei pagamenti: $e");
    }
  }

  Future<void> _loadYearlyPayments() async {
    try {
      List<Payment> p = await FirebaseHelper.retrieveYearlyPayments();
      setState(() {
        payments = p.toList();
      });
    } catch (e) {
      print("Errore durante il caricamento dei pagamenti: $e");
    }
  }

  Future<void> _loadCollaborators() async {
    try {
      collaborators = await FirebaseHelper.getAllCollaborators();
    } catch (e) {
      print("Errore durante il caricamento dei collaboratori: $e");
    }
  }

  void showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Conferma'),
          content: Text('Tutte le modifiche andranno perse'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, voglio restare'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                widget.changeTab(Menu.LEZIONI_NON_CONVALIDATE.index);
              },
              child: Text(
                'Esci senza salvare',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessSnackbar(bool paid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: paid ? 'Registrata!' : 'Eliminato!',
          message: paid ? 'Pagamento inserito correttamente' : 'Pagamento rimosso correttamente',
          contentType: ContentType.success,
        ),
      ),
    );
  }

  void showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Azione bloccata!',
          message: 'Alcuni collaboratori non hanno una paga impostata',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  void showConfirmPaymentsDialog(Collaborator collaborator) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Conferma'),
          content: Text(
              'Sei sicuro di voler segnare tutti i pagamenti di ${collaborator.name} come effettuati?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _registerPayment(collaborator);
                // showSuccessSnackbar();
              },
              child: Text(
                'Si, registra i pagamenti',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Funzione stub per registrare il pagamento per il collaboratore
  Future<void> _registerPayment(Collaborator collaborator) async {
    if (paymentsGrouped[collaborator.name] == null) {
      showErrorSnackbar();
      return;
    }
    for (Payment payment in payments) {
      if (payment.name == collaborator.name) {
        await registerSinglePayment(payment, true);
      }
    }
    await _loadPayments();
  }

  Future<void> registerSinglePayment(Payment payment, bool paid) async {
    Payment updatedPayment = Payment(
      name: payment.name,
      amount: payment.amount,
      date: payment.date,
      paid: paid,
      lessonId: payment.lessonId,
    );
    await FirebaseHelper.updatePayment(updatedPayment..id = payment.id);
  }

  // Future<void> generateCollaboratorPDF(
  //     Collaborator collaborator, int grossAmount) async {
  //   // Carica un font che supporta Unicode (assicurati di aver configurato correttamente l'asset nel pubspec.yaml)
  //   final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  //   final ttf = pw.Font.ttf(fontData.buffer.asByteData());
  //
  //   final pdf = pw.Document();
  //
  //   // Utilizza il font personalizzato in tutti gli stili di testo
  //   final defaultTextStyle =
  //   pw.TextStyle(font: ttf, fontFallback: [ttf], fontSize: 12);
  //
  //   // Calcola ritenuta e netto
  //   final double tax = grossAmount * 0.20;
  //   final double net = grossAmount - tax;
  //
  //   // Date fisse per l'esempio
  //   final String receiptDate = "30 Novembre 2024";
  //   final String periodDate = "26 Novembre 2024";
  //
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text("Lettere16",
  //                 style: defaultTextStyle.copyWith(fontSize: 16)),
  //             pw.SizedBox(height: 10),
  //             pw.Text("NOME: TOMMASO", style: defaultTextStyle),
  //             pw.Text("COGNOME: CARLINI", style: defaultTextStyle),
  //             pw.Text("INDIRIZZO:  Via F. Carletti, 7", style: defaultTextStyle),
  //             pw.Text("CAP:   00154", style: defaultTextStyle),
  //             pw.Text("Città:   Roma", style: defaultTextStyle),
  //             pw.Text("C.F.:   CRLTMS97D04H501P", style: defaultTextStyle),
  //             pw.Text("NATO/A A: Roma", style: defaultTextStyle),
  //             pw.Text("IL:        04 Aprila 1997", style: defaultTextStyle),
  //             pw.SizedBox(height: 10),
  //             pw.Text("Spett.le", style: defaultTextStyle),
  //             pw.SizedBox(height: 5),
  //             pw.Text("O-SERVICE S.R.L. (società unipersonale)",
  //                 style: defaultTextStyle),
  //             pw.Text("via LUIGI IAFFEI 11", style: defaultTextStyle),
  //             pw.Text("00052 Cerveteri (ROMA)", style: defaultTextStyle),
  //             pw.Text("P. IVA/C.F. 17429751005", style: defaultTextStyle),
  //             pw.SizedBox(height: 10),
  //             pw.Text("RICEVUTA DEL: $receiptDate", style: defaultTextStyle),
  //             pw.SizedBox(height: 10),
  //             pw.Text("Il/La sottoscritto/a       TOMMASO CARLINI",
  //                 style: defaultTextStyle),
  //             pw.Text(
  //               "dichiara di ricevere la somma lorda di euro ${grossAmount.toStringAsFixed(2)} "
  //                   "(euro ${grossAmount.toStringAsFixed(2)}/00) per l’attività occasionale di",
  //               style: defaultTextStyle,
  //             ),
  //             pw.Text("collaborazione relativa a:", style: defaultTextStyle),
  //             pw.Text("Istruttore di Orienteering", style: defaultTextStyle),
  //             pw.SizedBox(height: 5),
  //             pw.Text("svolta nel periodo: $periodDate", style: defaultTextStyle),
  //             pw.SizedBox(height: 5),
  //             pw.Text(
  //               "Al suddetto importo lordo andrà detratta ritenuta d'acconto (20%) pari a:",
  //               style: defaultTextStyle,
  //             ),
  //             pw.Text(
  //                 "euro ${tax.toStringAsFixed(2)} (euro ${tax.toStringAsFixed(2)}/00)",
  //                 style: defaultTextStyle),
  //             pw.SizedBox(height: 5),
  //             pw.Text(
  //                 "NETTO A PAGARE: euro ${net.toStringAsFixed(2)} (euro ${net.toStringAsFixed(2)}/00)",
  //                 style: defaultTextStyle),
  //             pw.SizedBox(height: 10),
  //             pw.Text(
  //               "Il/la sottoscritto/a dichiara inoltre sotto la propria responsabilità che la prestazione è stata resa",
  //               style: defaultTextStyle,
  //             ),
  //             pw.Text(
  //               "all’azienda in completa autonomia e con carattere del tutto occasionale non svolgendo tale",
  //               style: defaultTextStyle,
  //             ),
  //             pw.Text("prestazione di lavoro autonomo con carattere di abitualità.",
  //                 style: defaultTextStyle),
  //             pw.SizedBox(height: 5),
  //             pw.Text(
  //               "Il/la sottoscritto/a dichiara altresì di non aver superato la somma di €5000,00 (euro",
  //               style: defaultTextStyle,
  //             ),
  //             pw.Text(
  //                 "cinquemila/00) per tutte le prestazioni occasioni di qualsiasi natura svolte nell’anno in corso.",
  //                 style: defaultTextStyle),
  //             pw.SizedBox(height: 10),
  //             pw.Text("Data: $receiptDate", style: defaultTextStyle),
  //             pw.SizedBox(height: 20),
  //             pw.Text("In fede", style: defaultTextStyle),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   if (kIsWeb) {
  //     await Printing.layoutPdf(
  //         onLayout: (PdfPageFormat format) async => pdf.save());
  //   } else {
  //     await Printing.sharePdf(
  //       bytes: await pdf.save(),
  //       filename: '${collaborator.name}_payment.pdf',
  //     );
  //   }
  // }

  // Aggiorna la mappa dei pagamenti raggruppati per collaboratore
  void _updatePayments() {
    paymentsGrouped.clear();
    for (var payment in payments) {
      paymentsGrouped[payment.name] =
          (paymentsGrouped[payment.name] ?? 0) + payment.amount;
    }
  }

  // Quando si cambia mese, carica nuovamente i pagamenti e aggiorna la mappa
  void updateMonth(Month month) async {
    setState(() {
      selectedMonth = month;
      isLoading = true;
    });
    await _loadPayments();
    setState(() {
      _updatePayments();
      isLoading = false;
    });
  }

  // Nuova funzione per visualizzare una riga per un singolo Payment (non raggruppato)
  Widget paymentItemRow(Payment payment, double width) {
    double tax = payment.amount * 0.20;
    double net = payment.amount - tax;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.2,
            child: Text(
              "${payment.name} - ${payment.date.toString().substring(0, 10)}",
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            "Totale lordo: ${payment.amount.toString()}.00 €",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          Text(
            "Ritenuta (20%): ${tax.toStringAsFixed(2)} €",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          Text(
            "Totale netto: ${net.toStringAsFixed(2)} €",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 16),
          // Bottone per registrare il pagamento
          Tooltip(
            message: payment.paid ? "Segna come da pagare" : "Segna come pagato",
            child: ElevatedButton(
              onPressed: () async {
                await registerSinglePayment(payment, !payment.paid);
                setState(() {
                  _loadPayments();
                });
                showSuccessSnackbar(!payment.paid);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: payment.paid ? Colors.green : Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(
                payment.paid ? Icons.verified_rounded : Icons.highlight_off_rounded,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Bottone per aprire il PDF
          // ElevatedButton(
          //   onPressed: () => generateCollaboratorPDF(
          //       collaborators.firstWhere((c) => c.name == payment.name,
          //           orElse: () => Collaborator(name: payment.name)),
          //       payment.amount),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue.shade700,
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //   ),
          //   child: Text(
          //     "PDF",
          //     style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //         fontFamily: 'Montserrat'),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget allPaymentsRow(Collaborator collaborator, int total) {
      int totalPaid = 0;
      int totalToPay = 0;
      for (Payment payment in payments) {
        if (payment.name == collaborator.name && payment.paid) {
          totalPaid += payment.amount;
        } else if (payment.name == collaborator.name && !payment.paid) {
          totalToPay += payment.amount;
        }
      }
      return total == 0
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: width * 0.15,
                  child: Text(
                    collaborator.name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Totale dovuto al collaboratore: $total.00 €",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Di cui $totalPaid.00 € già versati.",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Totale mancante: $totalToPay.00 €",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  child: Row(
                    children: [
                      Tooltip(
                        message: totalToPay == 0 ? "Tutto saldato" : "Segna come pagato",
                        child: ElevatedButton(
                          onPressed: () {
                            totalToPay == 0 ? null :
                            showConfirmPaymentsDialog(collaborator);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: totalToPay == 0 ? Colors.green : Colors.orange,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Icon(
                            totalToPay == 0 ? Icons.verified_rounded : Icons.highlight_off_rounded,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                )
              ],
            );
    }

    return Card(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(160),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Intestazione con selezione mese e switch per raggruppamento
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pagamenti per ",
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ),
                MonthsDropdown(
                  initialMonth: selectedMonth,
                  onChanged: (Month month) {
                    updateMonth(month);
                  },
                ),
                SizedBox(width: 60),
                Tooltip(
                  message: groupPayments
                      ? "Mostra l'elenco completo"
                      : "Raggruppa per collaboratore",
                  child: Switch(
                    onChanged: (bool value) {
                      setState(() {
                        groupPayments = value;
                      });
                    },
                    value: groupPayments,
                    activeColor: Colors.orange,
                  ),
                ),
                Icon(
                  groupPayments ? Icons.account_tree_rounded : Icons.person,
                  color: Colors.indigo,
                ),
              ],
            ),
            SizedBox(height: 30),
            // Visualizzazione dei dati: se groupPayments è true raggruppa per collaboratore,
            // altrimenti elenca tutti i Payment individualmente.
            groupPayments
                ? Column(
                    children: collaborators.map((collaborator) {
                      int total = paymentsGrouped[collaborator.name] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: allPaymentsRow(collaborator, total),
                      );
                    }).toList(),
                  )
                : Column(
                    children: payments
                        .map((payment) => paymentItemRow(payment, width))
                        .toList(),
                  ),
            SizedBox(height: 30),
            // Pulsanti finali
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      textStyle: TextStyle(color: Colors.white),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      widget.changeTab(Menu.IMPOSTAZIONI.index);
                      Menu.screenRouting(
                          Menu.IMPOSTAZIONI.index, widget.changeTab, widget.menu);
                    },
                    child: Text(
                      "Fatto!",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
