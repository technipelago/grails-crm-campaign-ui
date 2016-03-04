<%@ page import="org.apache.commons.lang.StringUtils" %>
<g:each in="${result}" var="r">
    <tr class="crm-recipient ${r.dateOptOut ? 'crm-optout' : (r.reason ? 'crm-error' : (r.dateOpened ? 'crm-opened' : ''))}"
        data-crm-total="${totalCount}" data-crm-offset="${params.offset ?: 0}" data-crm-max="${params.max ?: 25}">

        <td>
            <g:link action="showRecipient" id="${r.id}" class="crm-info">
                <g:fieldValue bean="${r}" field="email"/>
            </g:link>
        </td>

        <td class="nowrap"><g:formatDate type="datetime" style="short" date="${r.dateSent}"/></td>
        <td class="nowrap"><g:formatDate type="datetime" style="short" date="${r.dateOpened}"/></td>
        <td style="color: #990000;">
            <g:if test="${r.reason}">
                ${org.apache.commons.lang.StringUtils.abbreviate(r.reason, 120).encodeAsHTML()}
            </g:if>
        </td>
        <td>
            <input type="checkbox" name="recipients" value="${r.id}"/>
        </td>
    </tr>
</g:each>