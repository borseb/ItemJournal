codeunit 50400 "Approval Mgmt Ext."
{
    trigger OnRun()
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnSendItemJnlForApproval(Var ItemJnl: record "Item Journal Line")
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnCancelItemJnlForApproval(Var ItemJnl: record "Item Journal Line")
    var

    begin

    end;

    procedure CheckItemJnlApprovalWorkflowEnable(var ItemJnl: Record "Item Journal Line"): Boolean
    var
    begin
        IF Not IsItemJnlDocApprovalsWorkflowEnable(ItemJnl) then
            Error(NoworkFlowEnableErr);
        exit(true);
    end;

    procedure IsItemJnlDocApprovalsWorkflowEnable(var ItemJnl: Record "Item Journal Line"): Boolean
    Begin
        IF ItemJnl."Approval Status" <> ItemJnl."Approval Status"::Open then
            exit(false);
        exit(WorkflowManagement.CanExecuteWorkflow(ItemJnl, WorkFlowEventHandlingCust.RunWorkflowOnSendItemJnlForApprovalCode));

    End;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry";
                    WorkflowStepInstance: Record "Workflow Step Instance")
    var
        ItemJnl: record "Item Journal Line";
    begin
        case RecRef.Number of
            database::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnl);
                    ApprovalEntryArgument."Document No." := ItemJnl."No.";
                end;
        end;
    end;
    //KPMG-BRB  Craete this event to flow Amount of ItemJnl table to Default field of Approval entry amount.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeApprovalEntryInsert', '', true, true)]
    local procedure OnBeforeApprovalEntryInsert(var ApprovalEntry: Record "Approval Entry"; ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepArgument: Record "Workflow Step Argument"; ApproverId: Code[50]; var IsHandled: Boolean)
    var
        ItemJnl: Record "Item Journal Line";
    begin
        // ItemJnl.Reset();
        // ItemJnl.SetRange("No.", ApprovalEntry."Document No.");
        // IF ItemJnl.FindFirst() then begin
        //     ItemJnl.CalcFields("Total Amount");
        //     ApprovalEntry.Amount := ItemJnl."Total Amount";
        //     ApprovalEntry."Amount (LCY)" := ItemJnl."Total Amount";
        // end;
    end;
    //Approval Date
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', true, true)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    begin
        SalesHeader."Approved Date" := Today;
    end;

    // [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnBeforeCheckAvailableCreditLimit', '', true, true)]
    // local procedure OnBeforeCheckAvailableCreditLimit(var SalesHeader: Record "Sales Header"; var ReturnValue: Decimal; var IsHandled: Boolean)
    // begin
    //     IsHandled := true;
    // end;

    var
        NoworkFlowEnableErr: TextConst ENU = 'No approval workflow for this record type is enabled.';
        WorkflowManagement: Codeunit 1501;
        WorkFlowEventHandlingCust: Codeunit 50401;
}
