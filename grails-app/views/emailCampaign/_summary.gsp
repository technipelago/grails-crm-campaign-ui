<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>E-postutskick</h4>

<p>
    Kampanjen är ${bean.active ? 'aktiv' : 'inaktiv'}
    <g:if test="${bean.parent}">och ingår i ${bean.parent}</g:if>
</p>

<p>
    Utskickets rubrik är <strong>${StringUtils.abbreviate(cfg.subject, 40)}</strong>
    och avsändare är <strong>${StringUtils.abbreviate(cfg.sender, 20)}</strong>.
</p>

<g:if test="${recipients}">
    Utskicket har skickats till ${recipients} st mottagare.
</g:if>
<g:else>
    Utskicket har inte skickats till några mottagare än.
</g:else>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>