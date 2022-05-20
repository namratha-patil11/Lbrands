<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Placement_Content_Send_Email_Alert_for_Approval</fullName>
        <description>Placement Content: Send Email Alert for Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>Placement_Library_Approval</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DGTL/Placement_Content_Approval</template>
    </alerts>
    <rules>
        <fullName>Send Approval Alert for Updating Placement Content</fullName>
        <actions>
            <name>Placement_Content_Send_Email_Alert_for_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Placement_Content__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
