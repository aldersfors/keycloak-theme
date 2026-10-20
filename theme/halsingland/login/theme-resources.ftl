<#-- Copied verbatim from Keycloak 26.8.1 base/login/theme-resources.ftl, which template.ftl
     imports. Servers before 26.8 do not ship it, so the theme carries its own copy; on 26.8+
     this copy shadows the identical one in base. Refresh it with the template head. -->
<#-- Keep synchronized with the other theme-resources.ftl copies under themes/. -->
<#macro renderStyles resources pathPrefix>
    <#list resources as resource>
        <link href="${pathPrefix}/${resource.path}" rel="stylesheet"<#if resource.media?has_content> media="${resource.media}"</#if><#if resource.integrity?has_content> integrity="${resource.integrity}"</#if><#if resource.crossorigin?has_content> crossorigin="${resource.crossorigin}"</#if> />
    </#list>
</#macro>

<#macro renderScripts resources pathPrefix defaultScriptType="">
    <#list resources as resource>
        <script src="${pathPrefix}/${resource.path}"<#if resource.type?has_content> type="${resource.type}"<#elseif defaultScriptType?has_content> type="${defaultScriptType}"</#if><#if resource.integrity?has_content> integrity="${resource.integrity}"</#if><#if resource.crossorigin?has_content> crossorigin="${resource.crossorigin}"</#if><#if resource.hasDefer()> defer</#if><#if resource.hasAsync()> async</#if><#if resource.blocking?has_content> blocking="${resource.blocking}"</#if>></script>
    </#list>
</#macro>

<#macro renderFavicons resources pathPrefix>
    <#list resources as resource>
        <link rel="${resource.rel!"icon"}"<#if resource.type?has_content> type="${resource.type}"</#if> href="${pathPrefix}/${resource.path}"<#if resource.media?has_content> media="${resource.media}"</#if> />
    </#list>
</#macro>
