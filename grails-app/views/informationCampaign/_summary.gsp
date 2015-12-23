<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>Informationskampanj</h4>

<p>
    Kampanjen är ${bean.active ? 'aktiv' : 'inaktiv'}
    <g:if test="${bean.parent}">och ingår i ${bean.parent}</g:if>
</p>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>