<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Placement_Library_Send_Email_Alert_to_Queue_Offer_Type</fullName>
        <description>Placement Library: Send Email Alert to Queue (Offer Type)</description>
        <protected>false</protected>
        <recipients>
            <recipient>Placement_Library_Approval</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DGTL/Placement_Library_Approval</template>
    </alerts>
    <rules>
        <fullName>Send Approval Alert for Offer Type Placement Library</fullName>
        <actions>
            <name>Placement_Library_Send_Email_Alert_to_Queue_Offer_Type</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Placement_Library__c.Offer_Type__c</field>
            <operation>equals</operation>
            <value>Offer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
