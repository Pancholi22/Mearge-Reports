// codeunit 50300 "Event Subscriber"
// {
//     [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterSetRec, '', false, false)]
//     local procedure Navigate_OnAfterSetRec(var Sender: Page Navigate; NewSourceRecVar: Variant)
//     var
//         PDFData: Record PdfData;
//     begin
//         PDFData.Reset();
//         if PDFData.get(1) then
//             NewSourceRecVar := PDFData;
//         // Sender.SetSource(, 'invoice', 'PS-INV103229', 1, 'PS-INV103229');
//     end;

//     // [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterShowRecords, '', false, false)]
//     // local procedure OnAfterShowRecords(var Sender: Page Navigate; TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceCrMemoHeader: Record "Service Cr.Memo Header"; ContactType: Enum "Navigate Contact Type"; ContactNo: Code[250]; ExtDocNo: Code[250])
//     // var
//     //     PDFData: Record PdfData;
//     // begin
//     //     PDFData.Reset();
//     //     PDFData.SetRange(EntryNo, 1);
//     //     if TableID = 50300 then begin
//     //         Page.Run(50300, PDFData);
//     //     end;
//     // end;
//     [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterShowRecords, '', false, false)]
//     local procedure Navigate_OnAfterShowRecords(var Sender: Page Navigate; var DocumentEntry: Record "Document Entry" temporary; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; ContactType: Enum "Navigate Contact Type"; ContactNo: Code[250]; ExtDocNo: Code[250])
//     var
//         PDFData: Record PdfData;
//     begin
//         PDFData.Reset();
//         PDFData.SetRange(EntryNo, 1);
//         if DocumentEntry."Table ID" = 50300 then begin
//             Page.Run(50300, PDFData);
//         end;
//     end;

// [EventSubscriber(ObjectType::Page, Page::Navigate, OnAfterNavigateFindRecords, '', false, false)]
//     local procedure Navigate_OnAfterNavigateFindRecords(var Sender: Page Navigate; var DocumentEntry: Record "Document Entry" temporary; DocNoFilter: Text; PostingDateFilter: Text; var NewSourceRecVar: Variant; ExtDocNo: Code[250]; HideDialog: Boolean)
//     var
//         RTHeatEntry: Record "Heat Entry";
//         MatriksDoc: Record "Matriks Doc Document";
//         PostedInvAdjmtHeader: Record "Posted Inv Adjmt. Header";
//         LinksMgt: Codeunit "Matriks Doc Links Management";
//         RTHeatMgt: Codeunit "Heat Management";
//         SingleInsNavigate: Codeunit "Single Instance Navigate";
//     begin
//         // SingleInsNavigate.SetDocNoFilter(DocNoFilter);
//         // SingleInsNavigate.SetDocEntry(DocumentEntry);
//         if PostedInvAdjmtHeader.ReadPermission then begin
//             PostedInvAdjmtHeader.Reset;
//             PostedInvAdjmtHeader.SetFilter("No.", DocNoFilter);
//             Sender.InsertIntoDocEntry(DocumentEntry, DATABASE::"Posted Inv Adjmt. Header", 0, PostedInvAdjmtHeader.TableCaption, PostedInvAdjmtHeader.Count);
//             // SingleInsNavigate.SetPostedInvAdjmtHeader(PostedInvAdjmtHeader);
//         end;

//         if DocumentEntry.ReadPermission then begin
//             Sender.InsertIntoDocEntry(DocumentEntry, Database::"Matriks Doc Document", 0, MatriksDoc.TableCaption, LinksMgt.FoundRecordsCount(DocNoFilter, PostingDateFilter));
//         end;

//         if RTHeatEntry.ReadPermission then begin
//             Sender.InsertIntoDocEntry(DocumentEntry, DATABASE::"Heat Entry", 0, RTHeatEntry.TableCaption, RTHeatMgt.FoundRecordsCount(DocNoFilter, PostingDateFilter));
//         end;
//     end;



// }
