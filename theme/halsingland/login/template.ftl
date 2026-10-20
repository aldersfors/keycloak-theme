<#import "field.ftl" as field>
<#import "footer.ftl" as loginFooter>
<#import "theme-resources.ftl" as themeResourceTags>
<#macro username>
  <#assign label>
    <#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>
  </#assign>
  <@field.group name="username" label=label>
    <div class="${properties.kcInputGroup}">
      <div class="${properties.kcInputGroupItemClass} ${properties.kcFill}">
        <span class="${properties.kcInputClass} ${properties.kcFormReadOnlyClass}">
          <input id="kc-attempted-username" value="${auth.attemptedUsername}" readonly>
        </span>
      </div>
      <div class="${properties.kcInputGroupItemClass}">
        <button id="reset-login" class="${properties.kcFormPasswordVisibilityButtonClass} kc-login-tooltip" type="button" 
              aria-label="${msg('restartLoginTooltip')}" onclick="location.href='${url.loginRestartFlowUrl}'">
            <i class="fa-sync-alt fas" aria-hidden="true"></i>
            <span class="kc-tooltip-text">${msg("restartLoginTooltip")}</span>
        </button>
      </div>
    </div>
  </@field.group>
</#macro>

<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="color-scheme" content="light${darkMode?then(' dark', '')}">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <#-- Keycloak 26.8+ passes title; older servers do not, so fall back to their loginTitle. -->
    <title>${title!msg("loginTitle",(realm.displayName!''))}</title>
    <#if themeResources?? && themeResources.favicons?has_content>
        <@themeResourceTags.renderFavicons themeResources.favicons url.resourcesPath />
    <#else>
        <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    </#if>
    <#if themeResources?? && themeResources.stylesCommon?has_content>
        <@themeResourceTags.renderStyles themeResources.stylesCommon url.resourcesCommonPath />
    <#elseif properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if themeResources?? && themeResources.styles?has_content>
        <@themeResourceTags.renderStyles themeResources.styles url.resourcesPath />
    <#elseif properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <script type="importmap">
        {
            "imports": {
                "rfc4648": "${url.resourcesCommonPath}/vendor/rfc4648/rfc4648.js"
            }
        }
    </script>
    <#if darkMode>
      <script type="module" async blocking="render">
          <#outputformat "JavaScript">
          const DARK_MODE_CLASS = ${properties.kcDarkModeClass?c};
          const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

          updateDarkMode(mediaQuery.matches);
          mediaQuery.addEventListener("change", (event) => updateDarkMode(event.matches));

          function updateDarkMode(isEnabled) {
            const { classList } = document.documentElement;

            if (isEnabled) {
              classList.add(DARK_MODE_CLASS);
            } else {
              classList.remove(DARK_MODE_CLASS);
            }
          }
          </#outputformat>
      </script>
    </#if>
    <#if themeResources?? && themeResources.scripts?has_content>
        <@themeResourceTags.renderScripts themeResources.scripts url.resourcesPath "text/javascript" />
    <#elseif properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <script type="module" src="${url.resourcesPath}/js/passwordVisibility.js"></script>
    <script type="module">
        <#outputformat "JavaScript">
        import { startSessionPolling } from ${(url.resourcesPath + "/js/authChecker.js")?c};

        startSessionPolling(
            ${url.ssoLoginInOtherTabsUrl?c}
        );
        </#outputformat>
    </script>
    <script type="module">
        document.addEventListener("click", (event) => {
            const link = event.target.closest("a[data-once-link]");

            if (!link) {
                return;
            }

            if (link.getAttribute("aria-disabled") === "true") {
                event.preventDefault();
                return;
            }

            const { disabledClass } = link.dataset;

            if (disabledClass) {
                link.classList.add(...disabledClass.trim().split(/\s+/));
            }

            link.setAttribute("role", "link");
            link.setAttribute("aria-disabled", "true");
        });
    </script>
    <#if authenticationSession??>
        <script type="module">
             <#outputformat "JavaScript">
            import { checkAuthSession } from ${(url.resourcesPath + "/js/authChecker.js")?c};

            checkAuthSession(
                ${authenticationSession.authSessionIdHash?c}
            );
            </#outputformat>
        </script>
    </#if>
    <script>
      // Workaround for https://bugzilla.mozilla.org/show_bug.cgi?id=1404468
      const isFirefox = true;
    </script>
</head>


<#-- halsingland frame: mobile-first, full-bleed on phones, a card from 600px up.
     Header (logo + realm), gold rule, page title, the page body, language switch last. -->
<body id="keycloak-bg" class="${properties.kcBodyClass!} hl-body" data-page-id="login-${pageId}">
<div class="hl-shell">
  <header id="kc-header" class="hl-header">
    <svg class="hl-logo" viewBox="0 0 251 305" fill="none" stroke="none" aria-hidden="true" focusable="false">
      <g transform="matrix(0.43,0,0,0.43,97.04,0.1)" fill="currentColor">
        <path d="m 154.67,45.09 41.87,0 c 2.77,0 5,2.23 5,5 l 0,535.75 c 0,0 -0.48,28.81 -25.86,28.83 -26.03,0.02 -26.01,-28.83 -26.01,-28.83 l 0,-535.75 c 0,-2.77 2.23,-5 5,-5 z"/>
        <path d="m 253.92,54.81 c 0,0 -167.87,0 -167.87,0 l 0,67.7 226.41,0 c 0,0 -24.51,-19.74 -58.54,-67.7 z"/>
      </g>
      <g transform="matrix(0.71,0,0,0.71,31.2,15.32)" fill="currentColor">
        <path d="m 17.8,339.79 c 6.54,-66.47 7.74,-139.79 10.64,-210.28 1.02,-24.88 9.14,-26.41 15.7,-33.04 21.48,-16.84 31.37,-24.58 31.37,-24.58 0,0 0,-55.5 0,-55.5 0.31,-8.57 4.93,-12.32 9.1,-5.33 0,0 6,71.74 6,71.74 0,0 -25.22,19.84 -38.06,32.27 -7.49,5.95 -7.92,7.91 -8.15,16.96 -2.06,79.66 -5.1,152.34 -11.81,211.91 -3.84,11.53 -17.27,9.02 -14.79,-4.16 z"/>
        <path transform="matrix(-1,0,0,1,108.93,0)" d="m 17.8,339.79 c 6.54,-66.47 7.74,-139.79 10.64,-210.28 1.02,-24.88 9.14,-26.41 15.7,-33.04 21.48,-16.84 31.37,-24.58 31.37,-24.58 0,0 0,-55.5 0,-55.5 0.31,-8.57 4.93,-12.32 9.1,-5.33 0,0 6,71.74 6,71.74 0,0 -25.22,19.84 -38.06,32.27 -7.49,5.95 -7.92,7.91 -8.15,16.96 -2.06,79.66 -5.1,152.34 -11.81,211.91 -3.84,11.53 -17.27,9.02 -14.79,-4.16 z"/>
        <circle cx="54.47" cy="99.57" r="4.22"/>
      </g>
    </svg>
    <span class="hl-realm">${(realm.displayName)!realm.name}</span>
  </header>

  <main class="hl-main">
    <div class="hl-rule" aria-hidden="true"></div>
    <h1 class="hl-title" id="kc-page-title"><#nested "header"></h1>

    <div class="hl-content">
      <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
          <#if displayRequiredFields>
              <div class="${properties.kcContentWrapperClass!}">
                  <div class="${properties.kcLabelWrapperClass!} subtitle">
                      <span class="${properties.kcInputHelperTextItemTextClass!}">
                        <span class="${properties.kcInputRequiredClass!}">*</span> ${msg("requiredFields")}
                      </span>
                  </div>
              </div>
          </#if>
      <#else>
          <#if displayRequiredFields>
              <div class="${properties.kcContentWrapperClass!}">
                  <div class="${properties.kcLabelWrapperClass!} subtitle">
                      <span class="${properties.kcInputHelperTextItemTextClass!}">
                        <span class="${properties.kcInputRequiredClass!}">*</span> ${msg("requiredFields")}
                      </span>
                  </div>
                  <div class="${properties.kcFormClass} ${properties.kcContentWrapperClass}">
                      <#nested "show-username">
                      <@username />
                  </div>
              </div>
          <#else>
              <div class="${properties.kcFormClass} ${properties.kcContentWrapperClass}">
                <#nested "show-username">
                <@username />
              </div>
          </#if>
      </#if>

      <#-- App-initiated actions should not see warning messages about the need to complete the action -->
      <#-- during login.                                                                               -->
      <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
          <div class="${properties.kcAlertClass!} pf-m-${(message.type = 'error')?then('danger', message.type)}">
              <div class="${properties.kcAlertIconClass!}">
                  <#if message.type = 'success'><span class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                  <#if message.type = 'warning'><span class="${properties.kcFeedbackWarningIcon!}"></span></#if>
                  <#if message.type = 'error'><span class="${properties.kcFeedbackErrorIcon!}"></span></#if>
                  <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
              </div>
              <span class="${properties.kcAlertTitleClass!} kc-feedback-text">${message.summary}</span>
          </div>
      </#if>

      <#nested "form">

      <#if auth?has_content && auth.showTryAnotherWayLink()>
        <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post" novalidate="novalidate">
            <input type="hidden" name="tryAnotherWay" value="on"/>
            <a id="try-another-way" href="javascript:document.forms['kc-select-try-another-way-form'].requestSubmit()"
                class="${properties.kcButtonSecondaryClass} ${properties.kcButtonBlockClass} ${properties.kcMarginTopClass}">
                  ${msg("doTryAnotherWay")}
            </a>
        </form>
      </#if>

      <#if switchOrganizationEnabled?? && switchOrganizationEnabled>
        <form id="kc-switch-organization-form" action="${url.loginAction}" method="post" novalidate="novalidate">
            <input type="hidden" name="switchOrganization" value="true"/>
            <a id="switch-organization" href="javascript:document.forms['kc-switch-organization-form'].requestSubmit()"
                class="${properties.kcButtonSecondaryClass} ${properties.kcButtonBlockClass} ${properties.kcMarginTopClass}">
                  ${msg("doSwitchOrganization")}
            </a>
        </form>
      </#if>

      <div class="hl-footer">
          <#nested "socialProviders">

          <#if displayInfo>
              <div id="kc-info" class="hl-info">
                  <div id="kc-info-wrapper">
                      <#nested "info">
                  </div>
              </div>
          </#if>
          <@loginFooter.content/>
      </div>
    </div>
  </main>

  <#if realm.internationalizationEnabled && locale.supported?size gt 1>
  <footer class="hl-lang">
    <label class="hl-sr-only" for="login-select-toggle">${msg("languages")}</label>
    <select id="login-select-toggle" onchange="if (this.value) window.location.href=this.value">
      <#list locale.supported?sort_by("label") as l>
        <option value="${l.url}" ${(l.languageTag == locale.currentLanguageTag)?then('selected','')}>${l.label}</option>
      </#list>
    </select>
  </footer>
  </#if>
</div>
</body>
</html>
</#macro>
