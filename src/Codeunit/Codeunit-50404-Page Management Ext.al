codeunit 50404 "Page Management Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    begin
        if PageID = 0 then
            PageID := GetConditionalCardPageID(RecordRef)
    end;

    //Codeunit Extension of Workflow Management for cancel for Approval
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', true, true)]
    local procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; xVariant: Variant; var IsHandled: Boolean)
    var
        Recref: RecordRef;
        ItemJnl: Record "Item Journal Line";
        RecApprovalEntry: record "Approval Entry";
    begin
        Recref.GetTable(Variant);
        IF (RecRef.NUMBER = DATABASE::"Item Journal Line") AND (FunctionName = WorkFloHandExt.RunWorkflowOnCancelItemJnlApprovalCode()) THEN BEGIN
            IF NOT WorkflowManagement.FindEventworkflowStepInstance(ActionableWorkflowStepInstance, FunctionName, Variant, Variant) THEN BEGIN
                ItemJnl := Variant;
                CLEAR(RecApprovalEntry);
                RecApprovalEntry.SETRANGE("Table ID", DATABASE::"Item Journal Line");
                RecApprovalEntry.SETRANGE("Document No.", ItemJnl."No.");
                RecApprovalEntry.SETRANGE("Record ID to Approve", ItemJnl.RECORDID);
                RecApprovalEntry.SETFILTER(Status, '%1|%2', RecApprovalEntry.Status::Created, RecApprovalEntry.Status::Open);
                IF RecApprovalEntry.FINDSET() THEN
                    RecApprovalentry.MODIFYALL(Status, RecApprovalEntry.Status::Canceled);
                ItemJnl.VALIDATE("Approval Status", ItemJnl."Approval Status"::Open);
                ItemJnl.MODIFY();
                Variant := ItemJnl;
                MESSAGE('Item journal Order Approval Request has-been cancelled.');
            end;
        end;
    end;

    local procedure GetConditionalCardPageID(RecordRef: RecordRef): integer
    var
    begin
        case RecordRef.Number of
            database::"Item Journal Line":
                Exit(Page::"Item Journal");

        end;
    end;

    var
        WorkFloHandExt: Codeunit 50401;
        WorkflowManagement: Codeunit 1501;
        ActionableWorkflowStepInstance: Record "Workflow Step Instance";
}