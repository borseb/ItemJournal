codeunit 50401 "Workflow Event Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendItemJnlForApprovalCode, Database::"Item Journal Line", ItemJnlSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelItemJnlApprovalCode, Database::"Item Journal Line", ItemJnlApprovalRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    var
        myInt: Integer;
    begin
        case EventFunctionName of
            RunWorkflowOnCancelItemJnlApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelItemJnlApprovalCode, RunWorkflowOnSendItemJnlForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendItemJnlForApprovalCode);

        end;
    end;




    procedure RunWorkflowOnSendItemJnlForApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendItemJnlForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnSendItemJnlForApproval', '', true, true)]
    local procedure RunWorkflowOnSendItemJnlForApproval(var ItemJnl: Record "Item Journal Line")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendItemJnlForApprovalCode, ItemJnl);
    end;

    procedure RunWorkflowOnCancelItemJnlApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnCancelItemJnlApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnCancelItemJnlForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelItemJnlApproval(var ItemJnl: Record "Item Journal Line")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelItemJnlApprovalCode, ItemJnl);
    end;



    var
        WorkflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        ItemJnlSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a ItemJnl document is requested';
        ItemJnlApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a ItemJnl document is cancel';
}