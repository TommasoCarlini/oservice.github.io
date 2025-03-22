import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/payment.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/enums/menu.dart';
import 'package:oservice/enums/months.dart';
import 'package:oservice/widgets/dropdown/monthsDropdown.dart';
import 'package:oservice/widgets/utils/pdfHelper.dart';

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

  Map<String, int> paymentsGrouped = {};

  DateTime paymentDate = DateTime.now();

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

  void showConfirmDialog(Collaborator collaborator, int totalPaid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pagamenti mancanti'),
          content: Text(
              'Risultano pagamenti mancanti, aprire comunque la ricevuta?'),
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
                generateCollaboratorPdf(collaborator, totalPaid);
              },
              child: Text(
                'Si, conferma',
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
          message: paid
              ? 'Pagamento inserito correttamente'
              : 'Pagamento rimosso correttamente',
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

  void showWaitSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Ricevuto!',
          message: 'Attendi qualche secondo mentre genero il pfd...',
          contentType: ContentType.help,
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

  void showTaxInfoIncompleteDialog(Collaborator collaborator) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Informazioni di fatturazione'),
          content: Text(
              'Risultano mancanti le informazioni di fatturazione per ${collaborator.name}, le vuoi aggiungere adesso?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, annulla'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseHelper.setIdSavedTaxInfo(collaborator.id);
                Navigator.of(context).pop();
                widget.changeTab(Menu.TAX_INFO.index);
                Menu.screenRouting(
                    Menu.TAX_INFO.index, widget.changeTab, widget.menu);
                // showSuccessSnackbar();
              },
              child: Text(
                'Si',
              ),
            ),
          ],
        );
      },
    );
  }

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

  void _updatePayments() {
    paymentsGrouped.clear();
    for (var payment in payments) {
      paymentsGrouped[payment.name] =
          (paymentsGrouped[payment.name] ?? 0) + payment.amount;
    }
  }

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

  Widget paymentItemRow(Payment payment, double width) {
    double tax = payment.amount * 0.20;
    double net = payment.amount - tax;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
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
          // SizedBox(width: 16),
          // Text(
          //   "Ritenuta (20%): ${tax.toStringAsFixed(2)} €",
          //   style: TextStyle(
          //     color: Theme.of(context).primaryColorLight,
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // SizedBox(width: 16),
          // Text(
          //   "Totale netto: ${net.toStringAsFixed(2)} €",
          //   style: TextStyle(
          //     color: Theme.of(context).primaryColorLight,
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          SizedBox(width: 16),
          // Bottone per registrare il pagamento
          Tooltip(
            message:
                payment.paid ? "Segna come da pagare" : "Segna come pagato",
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
                payment.paid
                    ? Icons.verified_rounded
                    : Icons.highlight_off_rounded,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: paymentDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != paymentDate) {
      setState(() {
        paymentDate = picked;
      });
    }
  }

  Future<void> generateCollaboratorPdf(
      Collaborator collaborator, int amount) async {
    showWaitSnackbar();
    TaxInfo? taxInfo =
        await FirebaseHelper.getTaxInfoByCollaboratorId(collaborator.id);
    if (taxInfo == null) {
      showTaxInfoIncompleteDialog(collaborator);
      return;
    } else {
      await _selectDate(context);
      int numberOfPayments = payments
          .where((element) => element.name == collaborator.name)
          .length;
      await PdfHelper.generateCollaboratorPDF(
          taxInfo, amount, numberOfPayments, paymentDate);
    }
  }

  Future<void> generateSummaryPdf(
      Collaborator collaborator, Month month) async {
    showWaitSnackbar();
    List<Payment> payments =
        await FirebaseHelper.retrievePaymentsByCollaborator(
            evaluateYear(), month.number, collaborator.name);
    await PdfHelper.generateSummaryPdf(
        collaborator, month, evaluateYear(), payments);
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
                  "Totale dovuto: $total.00 €",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "$totalPaid.00 € già versati.",
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Mancante: $totalToPay.00 €",
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
                        message: totalToPay == 0
                            ? "Tutto saldato"
                            : "Segna come pagato",
                        child: ElevatedButton(
                          onPressed: () {
                            totalToPay == 0
                                ? null
                                : showConfirmPaymentsDialog(collaborator);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                totalToPay == 0 ? Colors.green : Colors.orange,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Icon(
                            totalToPay == 0
                                ? Icons.verified_rounded
                                : Icons.highlight_off_rounded,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Bottone per aprire il PDF
                      Tooltip(
                        message: "Genera ricevuta",
                        child: ElevatedButton(
                            onPressed: () => totalToPay != 0
                                ? showConfirmDialog(collaborator, totalPaid)
                                : generateCollaboratorPdf(
                                    collaborator, totalPaid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Icon(Icons.receipt_long_rounded)),
                      ),
                      SizedBox(width: 8),
                      // Bottone per aprire il PDF
                      Tooltip(
                        message: "Visualizza riepilogo",
                        child: ElevatedButton(
                            onPressed: () {
                              generateSummaryPdf(collaborator, selectedMonth);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey.shade700,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Icon(Icons.checklist_rtl_rounded)),
                      ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                        Menu.screenRouting(Menu.IMPOSTAZIONI.index,
                            widget.changeTab, widget.menu);
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
      ),
    );
  }
}
