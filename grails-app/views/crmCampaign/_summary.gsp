<%@ page import="org.apache.commons.lang.StringUtils" defaultCodec="html" %>
<h4>${bean.name}</h4>

<g:if test="${bean.parent}">
    <p>ingår i ${bean.parent}</p>
</g:if>

<g:if test="${bean.description}">
    <p>${StringUtils.abbreviate(bean.description, 150)}</p>
</g:if>