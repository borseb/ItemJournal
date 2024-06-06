codeunit 50402 "Workflow Response Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: recordref; var Handled: Boolean)
    var
        ItemJnl: record "Item Journal Line";
    begin
        case RecRef.Number of
            database::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnl);
                    ItemJnl."Approval Status" := ItemJnl."Approval Status"::Open;
                    ItemJnl.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: recordref; var Handled: Boolean)
    var
        ItemJnl: record "Item Journal Line";
    begin
        case RecRef.Number of
            database::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnl);
                    ItemJnl."Approval Status" := ItemJnl."Approval Status"::Released;
                    ItemJnl.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure OnSetStatusToPendingApproval(RecRef: recordref; Var Variant: Variant; var IsHandled: Boolean)
    var
        ItemJnl: record "Item Journal Line";
    begin
        case RecRef.Number of
            database::"Item Journal Line":
                begin
                    RecRef.SetTable(ItemJnl);
                    ItemJnl."Approval Status" := ItemJnl."Approval Status"::"Pending Approval";
                    ItemJnl.Modify();
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit 1521;
        WorkflowEventHandlingCust: Codeunit 50401;
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendItemJnlForApprovalCode());

            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendItemJnlForApprovalCode());

            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelItemJnlApprovalCode());

            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelItemJnlApprovalCode());

        end;
    end;

    var
        myInt: Integer;
}