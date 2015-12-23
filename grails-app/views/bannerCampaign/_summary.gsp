<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>Bannerkampanj</h4>

<p>
    Kampanjen är ${bean.active ? 'aktiv' : 'inaktiv'}
    <g:if test="${bean.parent}">och ingår i ${bean.parent}</g:if>
</p>

<p>
    Bilder visas i området <strong>${bean.code}</strong>.
</p>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>
