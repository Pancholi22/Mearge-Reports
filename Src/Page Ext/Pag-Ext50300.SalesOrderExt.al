pageextension 50300 "Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addafter("Attached Documents List")
        {
            part(PdfMearge; "Manage PDFs")
            {
                Caption = 'Manage PDFs';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(ProformaInvoice)
        {
            action("Print Document")
            {
                ApplicationArea = All;
                Image = Download;
                trigger OnAction()
                Var
                    SalesHeader: Record "Sales Header";
                    StandardSalesConf: Report "Standard Sales - Order Conf.";
                    Ostream: OutStream;
                    InStream: InStream;
                    TempBlob: Codeunit "Temp Blob";
                    FileName: Text;
                    DocumentAttachment: Record "Document Attachment";
                    RecordID: RecordId;
                    RecRef: RecordRef;
                begin
                    RecRef.Open(Database::"Sales Header");
                    RecordID := RecRef.RecordId;
                    SalesHeader.Reset();
                    DocumentAttachment.Reset();
                    SalesHeader.SetRange("No.", Rec."No.");
                    SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
                    DocumentAttachment.SetRange("Table ID", RecordID.TableNo);
                    DocumentAttachment.SetRange("No.", Rec."No.");
                    StandardSalesConf.SetTableView(SalesHeader);
                    // StandardSalesConf.RunModal();
                    if DocumentAttachment.FindSet() then begin
                        repeat
                            if DocumentAttachment."Document Reference ID".HasValue then begin
                                Clear(Tempblob);
                                Tempblob.CreateOutStream(Ostream);
                                Tempblob.CreateInStream(InStream);
                                FileName := 'CustomerStatement_' + UserId + '_' +
                                Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>') + '.pdf';
                                DocumentAttachment."Document Reference ID".ExportStream(Ostream);
                                DownloadFromStream(InStream, 'application/pdf', '', '', FileName);
                            end;
                        until DocumentAttachment.Next() = 0;
                    end;
                    // TempBlob.CreateOutStream(OStream);
                    // StandardSalesConf.SaveAs('', ReportFormat::Pdf, Ostream);
                    // TempBlob.CreateInStream(InStream);
                    // FileName := 'CustomerStatement_' + UserId + '_' +
                    // Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>') + '.pdf';
                    // DownloadFromStream(InStream, 'application/pdf', '', '', FileName);
                end;
            }
            action("Scan Doc")
            {
                ApplicationArea = All;
                Image = ScanDoc;

                trigger OnAction()
                begin
                    // Page.Run(Page::Scan);
                    Hyperlink('http://127.0.0.1:5501/Src/I_Scan-Documents/Hello-World.html');
                end;
            }
            action(RunHyperLinkInBC)
            {
                Caption = 'Run HyperLink in BC';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ZYHyperLink: Page "Scan Page";
                // Scan: Page Scan;
                begin
                    // Scan.Run();
                    ZYHyperLink.SetURL('https://127.0.0.1:5501/Src/I_Scan-Documents/Hello-World.html');
                    //ZYHyperLink.SetURL(GetUrl(ClientType::Current, Rec.CurrentCompany, ObjectType::Page, Page::"Customer List"));
                    ZYHyperLink.Run();
                end;
            }
        }
    }

    procedure AddReportToMerge(ReportID: Integer; RecRef: RecordRef)
    var
        TempBlob1: Codeunit "Temp Blob";
        Ins: InStream;
        Outs: OutStream;
        Parameters: Text;
        Convert: Codeunit "Base64 Convert";
        JObjectPDF: JsonObject;
    begin
        TempBlob1.CreateOutStream(Outs);
        Report.SaveAs(ReportID, Parameters, ReportFormat::Pdf, Outs, RecRef);

        TempBlob1.CreateInStream(Ins);
        JObjectPDF.Add('pdf', Convert.ToBase64(Ins));

        JArrayPDFToMerge.Add(JObjectPDF);
    end;

    procedure GetJArray() JArrayPDF: JsonArray;
    begin
        JArrayPDF := JArrayPDFToMerge;
    end;

    var
        JObjectPDFToMerge: JsonObject;
        JArrayPDFToMerge: JsonArray;
        Base64PDF, Base64PDF2 : Text;

    trigger OnOpenPage()

    var
        SalesHeader: Record "Sales Header";
        RecRef: RecordRef;
        FileName: Text;
        JArrayPDF: JsonArray;
        JsonItem: JsonToken;
        MergedInStream, IndividualPDFStream : InStream;
        MergedOutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        JsonToken: JsonToken;
        JsonElement: JsonObject;
        ProcessedBase64List: List of [Text];
        Iteration: Integer;
        ManagePdf: page "Manage PDFs";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", Rec."No.");

        if SalesHeader.FindFirst() then begin
            RecRef.GetTable(SalesHeader);

            Clear(JObjectPDFToMerge);

            // AddReportToMerge(Report::"Standard Sales - Order Conf.", RecRef);
            // AddReportToMerge(Report::"Work Order", RecRef);

            JArrayPDF := GetJArray();

            TempBlob.CreateOutStream(MergedOutStream);

            Iteration := 0;
            foreach JsonItem in JArrayPDF do begin
                if (Iteration >= 2) then
                    break;

                if JsonItem.IsObject() then begin
                    JsonElement := JsonItem.AsObject();

                    if JsonElement.Contains('pdf') and JsonElement.Get('pdf', JsonToken) and JsonToken.IsValue() then begin
                        if Iteration = 0 then begin
                            Base64PDF := JsonToken.AsValue().AsText();
                        end
                        else begin
                            Base64PDF2 := JsonToken.AsValue().AsText();

                        end;
                        if (Iteration = 0) and (Base64PDF <> '') and not ProcessedBase64List.Contains(Base64PDF) then begin
                            ProcessedBase64List.Add(Base64PDF);
                            Base64Convert.FromBase64(Base64PDF, MergedOutStream);
                            Iteration += 1;
                        end
                        else if (Iteration = 1) and (Base64PDF2 <> '') and not ProcessedBase64List.Contains(Base64PDF2) then begin
                            ProcessedBase64List.Add(Base64PDF2);
                            Base64Convert.FromBase64(Base64PDF2, MergedOutStream);
                            Iteration += 1;
                        end;
                    end;
                end;
            end;

            TempBlob.CreateInStream(MergedInStream);
            CopyStream(MergedOutStream, MergedInStream);
            FileName := 'Sales_Order_' + UserId + '_' +
                        Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>') + '.pdf';

            ManagePdf.GetBase64Data(Base64PDF, Base64PDF2, Rec, Rec."No.");
        end;
    end;

    procedure InsertData(SalesOrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        RecRef: RecordRef;
        FileName: Text;
        JArrayPDF: JsonArray;
        JsonItem: JsonToken;
        MergedInStream, IndividualPDFStream : InStream;
        MergedOutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        JsonToken: JsonToken;
        JsonElement: JsonObject;
        ProcessedBase64List: List of [Text];
        Iteration: Integer;
        ManagePdf: page "Manage PDFs";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", SalesOrderNo);

        if SalesHeader.FindFirst() then begin
            RecRef.GetTable(SalesHeader);

            Clear(JObjectPDFToMerge);

            AddReportToMerge(Report::"Standard Sales - Order Conf.", RecRef);
            AddReportToMerge(Report::"Work Order", RecRef);

            JArrayPDF := GetJArray();

            TempBlob.CreateOutStream(MergedOutStream);

            Iteration := 0;
            foreach JsonItem in JArrayPDF do begin
                if (Iteration >= 2) then
                    break;

                if JsonItem.IsObject() then begin
                    JsonElement := JsonItem.AsObject();

                    if JsonElement.Contains('pdf') and JsonElement.Get('pdf', JsonToken) and JsonToken.IsValue() then begin
                        if Iteration = 0 then begin
                            Base64PDF := JsonToken.AsValue().AsText();
                        end
                        else begin
                            Base64PDF2 := JsonToken.AsValue().AsText();

                        end;
                        if (Iteration = 0) and (Base64PDF <> '') and not ProcessedBase64List.Contains(Base64PDF) then begin
                            ProcessedBase64List.Add(Base64PDF);
                            Base64Convert.FromBase64(Base64PDF, MergedOutStream);
                            Iteration += 1;
                        end
                        else if (Iteration = 1) and (Base64PDF2 <> '') and not ProcessedBase64List.Contains(Base64PDF2) then begin
                            ProcessedBase64List.Add(Base64PDF2);
                            Base64Convert.FromBase64(Base64PDF2, MergedOutStream);
                            Iteration += 1;
                        end;
                    end;
                end;
            end;


            TempBlob.CreateInStream(MergedInStream);
            CopyStream(MergedOutStream, MergedInStream);
            FileName := 'Sales_Order_' + UserId + '_' +
                        Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>') + '.pdf';

            ManagePdf.GetBase64Data(Base64PDF, Base64PDF2, Rec, SalesOrderNo);
        end;
    end;
}
