import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/payment.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/enums/months.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfHelper {
  static Future<void> generateCollaboratorPDF(TaxInfo taxInfo, int grossAmount,
      int numberOfPayments, DateTime paymentDate) async {
    final fontData =
        await rootBundle.load("assets/fonts/Montserrat/Montserrat-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final fontDataBold =
        await rootBundle.load("assets/fonts/Montserrat/Montserrat-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontDataBold.buffer.asByteData());

    final pdf = pw.Document();

    // Utilizza il font personalizzato in tutti gli stili di testo
    final defaultTextStyle =
        pw.TextStyle(font: ttf, fontFallback: [ttf], fontSize: 12);

    final boldTextStyle = pw.TextStyle(
        font: ttf,
        fontFallback: [ttf],
        fontWeight: pw.FontWeight.bold,
        fontSize: 14);

    // Calcola ritenuta e netto
    final double tax = grossAmount * 0.20;
    final double net = grossAmount - tax;

    // Date fisse per l'esempio
    final String day = DateTime.now().day.toString();
    final String month = Month.fromNumber(DateTime.now().month).name;
    final String year = DateTime.now().year.toString();
    String currentDate = "$day $month $year";
    String paymentDateString =
        "${paymentDate.day} ${Month.fromNumber(paymentDate.month).name} ${paymentDate.year}";

    final String periodDate = "$month $year";

    String extractDate(String date) {
      List<String> dateParts = date.split("/");
      String day = dateParts[0];
      String month = Month.fromNumber(int.parse(dateParts[1])).name;
      String year = dateParts[2];
      return "$day $month $year";
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("NOME:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.name.toUpperCase(), style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("COGNOME:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.surname.toUpperCase(), style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("INDIRIZZO:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.address, style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("CAP:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.zipCode, style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("CITTÀ:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.city, style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("C.F.:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.fiscalCode, style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("NATO/A A:", style: defaultTextStyle),
                ),
                pw.Text(taxInfo.birthPlace, style: boldTextStyle)
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text("IL:", style: defaultTextStyle),
                ),
                pw.Text(extractDate(taxInfo.birthDate), style: boldTextStyle)
              ]),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Spett.le", style: defaultTextStyle),
                        pw.SizedBox(height: 5),
                        pw.Text("O-SERVICE S.R.L. (società unipersonale)",
                            style: defaultTextStyle),
                        pw.Text("via LUIGI IAFFEI 11", style: defaultTextStyle),
                        pw.Text("00052 Cerveteri (ROMA)",
                            style: defaultTextStyle),
                        pw.Text("P. IVA/C.F. 17429751005",
                            style: defaultTextStyle),
                      ]),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("RICEVUTA DEL: ", style: defaultTextStyle),
                  pw.Text(paymentDateString, style: boldTextStyle),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("Il/La sottoscritto/a       ",
                      style: defaultTextStyle),
                  pw.Text(
                      "${taxInfo.name.toUpperCase()} ${taxInfo.surname.toUpperCase()}",
                      style: boldTextStyle),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("dichiara di ricevere la somma lorda di ",
                      style: defaultTextStyle),
                  pw.Text(grossAmount.toStringAsFixed(2), style: boldTextStyle),
                  pw.Text(
                      " (euro ${digitToText(int.parse(grossAmount.toStringAsFixed(2).split(".").first))}/${grossAmount.toStringAsFixed(2).split(".").last}) per l’attività",
                      style: defaultTextStyle),
                ],
              ),
              pw.Text("occasionale di collaborazione relativa a:",
                  style: defaultTextStyle),
              pw.Text("Istruttore di Orienteering", style: boldTextStyle),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("svolta in ", style: defaultTextStyle),
                  numberOfPayments == 1
                      ? pw.Text("$numberOfPayments giorno",
                          style: boldTextStyle)
                      : pw.Text("$numberOfPayments giorni",
                          style: boldTextStyle),
                  pw.Text(" nel periodo:   ", style: defaultTextStyle),
                  pw.Text(periodDate, style: boldTextStyle),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                "Al suddetto importo lordo andrà detratta ritenuta d'acconto (20%) pari a:",
                style: defaultTextStyle,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text("euro ${tax.toStringAsFixed(2)} ",
                      style: boldTextStyle),
                  pw.Text(
                      "(euro ${digitToText(int.parse(tax.toStringAsFixed(2).split(".").first))}/${tax.toStringAsFixed(2).split(".").last})",
                      style: defaultTextStyle),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                  "NETTO A PAGARE: euro ${net.toStringAsFixed(2)} (euro ${digitToText(int.parse(net.toStringAsFixed(2).split(".").first))}/${net.toStringAsFixed(2).split(".").last})",
                  style: boldTextStyle),
              pw.SizedBox(height: 15),
              pw.Text(
                "Il/la sottoscritto/a dichiara inoltre sotto la propria responsabilità che la prestazione è stata resa all’azienda in completa autonomia e con carattere del tutto occasionale non svolgendo tale prestazione di lavoro autonomo con carattere di abitualità.",
                style: defaultTextStyle,
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                  "Il/la sottoscritto/a dichiara altresì di non aver superato la somma di €5000,00 (euro cinquemila/00) per tutte le prestazioni occasioni di qualsiasi natura svolte nell’anno in corso.",
                  style: defaultTextStyle),
              pw.SizedBox(height: 15),
              pw.Text("Data: $paymentDateString", style: defaultTextStyle),
              pw.SizedBox(height: 20),
              pw.Text("In fede", style: defaultTextStyle),
            ],
          );
        },
      ),
    );

    showPdf(pdf, "${taxInfo.surname}_payment");
  }

  static String dateToString(DateTime date) {
    return "${date.day} ${Month.fromNumber(date.month).name} ${date.year}";
  }

  static pw.Widget paymentRow(
      Payment payment, Lesson lesson, pw.TextStyle defaultTextStyle) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(dateToString(payment.date), style: defaultTextStyle),
          pw.Text(lesson.entity.name, style: defaultTextStyle),
          pw.Text("${payment.amount.toStringAsFixed(2)} €",
              style: defaultTextStyle),
        ],
      ),
    );
  }

  static Future<Map<String, Lesson>> getLessons(List<Payment> payments) async {
    Map<String, Lesson> lessons = {};
    for (Payment payment in payments) {
      Lesson lesson = await FirebaseHelper.getLessonById(payment.lessonId);
      lessons[payment.id] = lesson;
    }
    return lessons;
  }

  static double getGrossAmount(List<Payment> payments) {
    double grossAmount = 0;
    for (Payment payment in payments) {
      grossAmount += payment.amount;
    }
    return grossAmount;
  }

  static Future<void> generateSummaryPdf(Collaborator collaborator, Month month,
      int year, List<Payment> payments) async {
    final fontData =
        await rootBundle.load("assets/fonts/Montserrat/Montserrat-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final fontDataBold =
        await rootBundle.load("assets/fonts/Montserrat/Montserrat-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontDataBold.buffer.asByteData());

    Map<String, Lesson> lessons = await getLessons(payments);

    final pdf = pw.Document();

    final defaultTextStyle =
        pw.TextStyle(font: ttf, fontFallback: [ttf], fontSize: 12);

    final boldTextStyle = pw.TextStyle(
        font: ttf,
        fontFallback: [ttf],
        fontWeight: pw.FontWeight.bold,
        fontSize: 14);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  "Riepilogo pagamenti di ${collaborator.name} - ${month.name} $year",
                  style: defaultTextStyle.copyWith(fontSize: 16)),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Data", style: boldTextStyle),
                  pw.Text("Ente", style: boldTextStyle),
                  pw.Text("Importo", style: boldTextStyle),
                ],
              ),
              pw.Divider(),
              pw.Column(
                children: payments.map((payment) {
                  return paymentRow(
                      payment, lessons[payment.id]!, defaultTextStyle);
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTALE: ", style: boldTextStyle),
                  pw.Text("${getGrossAmount(payments).toStringAsFixed(2)} €",
                      style: boldTextStyle),
                ],
              )
            ],
          );
        },
      ),
    );

    showPdf(pdf, "${collaborator.name}_summary");
  }

  static Future<void> showPdf(pw.Document pdf, String name) async {
    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$name.pdf',
      );
    }
  }

  static String digitToText(int amount) {
    final List<String> units = [
      "",
      "uno",
      "due",
      "tre",
      "quattro",
      "cinque",
      "sei",
      "sette",
      "otto",
      "nove"
    ];
    final List<String> tens = [
      "",
      "dieci",
      "venti",
      "trenta",
      "quaranta",
      "cinquanta",
      "sessanta",
      "settanta",
      "ottanta",
      "novanta"
    ];
    final List<String> teens = [
      "dieci",
      "undici",
      "dodici",
      "tredici",
      "quattordici",
      "quindici",
      "sedici",
      "diciassette",
      "diciotto",
      "diciannove"
    ];

    String text = "";
    int hundreds = amount ~/ 100;
    int tensAmount = amount % 100;
    int unitsAmount = tensAmount % 10;
    tensAmount = tensAmount ~/ 10;

    if (hundreds > 0) {
      if (hundreds == 1) {
        text += "cento";
      } else {
        text += "${units[hundreds]}cento";
      }
    }

    if (tensAmount > 0) {
      if (tensAmount == 1 && unitsAmount > 0) {
        text += teens[unitsAmount];
      } else {
        text += tens[tensAmount];
        if (unitsAmount > 0) {
          text += units[unitsAmount];
        }
      }
    } else {
      if (unitsAmount > 0) {
        text += units[unitsAmount];
      }
    }

    return text
        .replaceAll("aa", "a")
        .replaceAll("ee", "e")
        .replaceAll("oo", "o")
        .replaceAll("ii", "i")
        .replaceAll("uu", "u");
  }
}
