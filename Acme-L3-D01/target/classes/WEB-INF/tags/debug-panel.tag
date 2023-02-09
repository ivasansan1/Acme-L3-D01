<%--
- debug-panel.tag
-
- Copyright (C) 2012-2023 Rafael Corchuelo.
-
- In keeping with the traditional purpose of furthering education and research, it is
- the policy of the copyright owner to permit non-commercial use and redistribution of
- this software. It has been tested carefully, but it is not guaranteed for any particular
- purposes.  The copyright owner does not offer any warranties or representations, nor do
- they accept any liabilities with respect to them.
--%>

<%@tag import="org.springframework.web.util.WebUtils"%>
<%@tag language="java" body-content="empty" 
	import="
		java.util.Enumeration, 
		java.util.SortedMap,
		java.util.TreeMap,
		java.lang.StringBuilder,
		javax.servlet.jsp.PageContext,
		org.springframework.web.util.WebUtils,
		acme.framework.helpers.PrinterHelper,
		acme.framework.helpers.StringHelper,
		acme.framework.components.models.ModelKeyComparator
"%>

<%@taglib prefix="jstl" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="acme" uri="urn:jsptagdir:/WEB-INF/tags"%>

<%@attribute name="full" required="false" type="java.lang.Boolean"%>

<jstl:if test="${full == null}">
	<jstl:set var="full" value="${false}"/>
</jstl:if>

<%
	Cookie cookie;
	String serverName, debug;
	boolean showPanel;
	ModelKeyComparator comparator;
	SortedMap<String, Object[]> workAreaData, formPlainData, formIndexedData, supportData, internalData, otherData;
	String otherPattern;
	int scope;
	Enumeration<?> keys;
	StringBuilder buffer;

	serverName = request.getServerName();
	debug = request.getParameter("debug");
	if (debug == null) {
		cookie = WebUtils.getCookie(request, "debug");
		debug = cookie != null ? cookie.getValue() : "true";
	}
	debug = StringHelper.anyOf(debug, "true|false") ? debug : "true";
	showPanel = (debug.equals("true"));
	jspContext.setAttribute("showPanel", showPanel);
		
	if (showPanel) {
		comparator = new ModelKeyComparator();
		workAreaData = new TreeMap<String, Object[]>(comparator);
		formPlainData = new TreeMap<String, Object[]>(comparator);
		formIndexedData = new TreeMap<String, Object[]>(comparator);
		supportData = new TreeMap<String, Object[]>(comparator);
		internalData = new TreeMap<String, Object[]>(comparator);
		otherData = new TreeMap<String, Object[]>(comparator);
		
		otherPattern = "^(.*(__|\\.[A-Z][A-Z]|[sS][pP][rR][iI][nN][gG]|\\.[^.]+\\.).*)$";
		scope = PageContext.REQUEST_SCOPE;
		keys = jspContext.getAttributeNamesInScope(scope);
		buffer = new StringBuilder();			
		
		while (keys.hasMoreElements()) {
			String name;
			Object value;
			boolean selected;
			Object[] pair;
		
			name = (String) keys.nextElement();
			value = jspContext.getAttribute(name, scope);
			
			PrinterHelper.printObject(buffer, value, true);
			pair = new Object[] { buffer.toString(), value.getClass().getName() };
			buffer.setLength(0);
	
			if (name.matches(otherPattern)) 
				otherData.put(name, pair);
			else {
				if (StringHelper.anyOf(name, "$request|$buffer|$response"))
					workAreaData.put(name, pair);
				else if (name.startsWith("_"))
					supportData.put(name, pair);
				else if (name.contains("$"))
					internalData.put(name, pair);
				else if (!name.contains("["))
					formPlainData.put(name, pair);
				else
					formIndexedData.put(name, pair);
			}
		}
		jspContext.setAttribute("formPlainData", formPlainData);
		jspContext.setAttribute("formIndexedData", formIndexedData);
		jspContext.setAttribute("supportData", supportData);
		jspContext.setAttribute("internalData", internalData);
		jspContext.setAttribute("workAreaData", workAreaData);
		jspContext.setAttribute("otherData", otherData);
	}
%>

<jstl:if test="${showPanel}">
	<div class="panel mt-5 mb-5" style="word-wrap: break-word; font-family: monospace; font-size: small; background-color: LightGray; padding: 2em; border-radius: 0.25rem;">
		<div class="panel-body mb-3">
			<div class="alert alert-info" style="font-family: monospace; font-size: small;">
				<h2>User data</h2>
				<dl>		
					<jstl:forEach var="entry" items="${formPlainData.entrySet()}">
						<dt><jstl:out value="${entry.key}: ${entry.value[1]}"/></dt>
						<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${entry.value[0]}"/></dd>
					</jstl:forEach>			
					<jstl:forEach var="entry" items="${formIndexedData.entrySet()}">
						<dt><jstl:out value="${entry.key}: ${entry.value[1]}"/></dt>
						<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${entry.value[0]}"/></dd>
					</jstl:forEach>				
				</dl>
			</div>
			<div class="alert alert-info" style="font-family: monospace; font-size: small;">
				<h2>Support data</h2>
				<dl>		
					<jstl:forEach var="entry" items="${supportData.entrySet()}">
						<dt><jstl:out value="${entry.key}: ${entry.value[1]}"/></dt>
						<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${entry.value[0]}"/></dd>
					</jstl:forEach>				
				</dl>
			</div>
			<div class="alert alert-info" style="font-family: monospace; font-size: small;">
				<h2>Internal data</h2>
				<dl>		
					<jstl:forEach var="entry" items="${internalData.entrySet()}">
						<dt><jstl:out value="${entry.key}: ${entry.value[1]}"/></dt>
						<dd	style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${entry.value[0]}"/></dd>
					</jstl:forEach>
				</dl>
			</div>
			<div class="alert alert-info" style="font-family: monospace; font-size: small;">
				<h2>Work-area data</h2>
				<dl>		
					<dt><jstl:out value="$request: ${workAreaData.get('$request')[1]}"/></dt>
					<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${workAreaData.get('$request')[0]}"/></dd>
					<dt><jstl:out value="$buffer: ${workAreaData.get('$buffer')[1]}"/></dt>
					<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${workAreaData.get('$buffer')[0]}"/></dd>
					<dt><jstl:out value="$response: ${workAreaData.get('$response')[1]}"/></dt>
					<dd style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${workAreaData.get('$response')[0]}"/></dd>
				</dl>
			</div>
			<jstl:if test="${full == true}">
				<div class="alert alert-info" style="font-family: monospace; font-size: small;">
					<h2>Other data</h2>
					<dl>		
						<jstl:forEach var="entry" items="${otherData.entrySet()}">
							<dt><jstl:out value="${entry.key}: ${entry.value[1]}"/></dt>
							<dd	style="word-wrap: break-word; white-space: pre-wrap; margin-left: 1em;"><jstl:out value="${entry.value[0]}"/></dd>
						</jstl:forEach>
					</dl>
				</div>
			</jstl:if>										
		</div>
	</div>
</jstl:if>


