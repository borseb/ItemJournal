pageextension 50401 "Request To Approve_ext" extends "Requests to Approve"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here for Ststus not changed for RFQ Card as remain Pending for Approval
        //PCPL-25/240323
        modify(Approve)
        {
            trigger OnAfterAction()
            var
                ItemJnl: Record "Item Journal Line";
                AppEntr: Record "Approval Entry";
                SalesHdr: Record "Sales Header";
                PurchHdr: Record "Purchase Header";
            begin
                AppEntr.Reset();
                AppEntr.SetRange("Document No.", Rec."Document No.");
                AppEntr.SetRange("Table ID", 5740);
                AppEntr.SetRange(Status, AppEntr.Status::Approved);
                IF AppEntr.FindLast then begin
                    ItemJnl.Reset();
                    ItemJnl.SetRange("No.", AppEntr."Document No.");
                    ItemJnl.SetRange("Approval Status", ItemJnl."Approval Status"::"Pending Approval");
                    IF ItemJnl.FindFirst() then begin
                        ItemJnl."Approval Status" := ItemJnl."Approval Status"::Released;
                        ItemJnl."Approval Date" := Today;
                        ItemJnl.Modify();
                    end;
                end;

                AppEntr.Reset();
                AppEntr.SetRange("Document No.", Rec."Document No.");
                AppEntr.SetRange("Table ID", 36);
                AppEntr.SetRange(Status, AppEntr.Status::Approved);
                IF AppEntr.FindLast then begin
                    SalesHdr.Reset();
                    SalesHdr.SetRange("No.", AppEntr."Document No.");
                    SalesHdr.SetRange(SalesHdr.Status, SalesHdr.Status::Released);
                    IF SalesHdr.FindFirst() then begin
                        SalesHdr."Approved Date" := Today;
                        // SalesHdr."Approval Status" := SalesHdr."Approval Status"::Released;
                        //SalesHdr. := Today;
                        SalesHdr.Modify();
                    end;
                end;

                //Purchase
                // AppEntr.Reset();
                // AppEntr.SetRange("Document No.", Rec."Document No.");
                // AppEntr.SetRange("Table ID", 5740);
                // AppEntr.SetRange(Status, AppEntr.Status::Approved);
                // IF AppEntr.FindLast then begin
                //     ItemJnl.Reset();
                //     ItemJnl.SetRange("No.", AppEntr."Document No.");
                //     ItemJnl.SetRange("Approval Status", ItemJnl."Approval Status"::"Pending Approval");
                //     IF ItemJnl.FindFirst() then begin
                //         ItemJnl."Approval Status" := ItemJnl."Approval Status"::Released;
                //         ItemJnl."Approval Date" := Today;
                //         ItemJnl.Modify();
                //     end;
                // end;
            end;
        }
        //PCPL-25/240323
    }

    var
        myInt: Integer;
}