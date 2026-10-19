<#-- halsingland HTML email frame. Email clients ignore external CSS and web fonts, so the
     layout is tables with inline styles in the light palette. The <style> block only adds
     dark-mode colours for clients that honour prefers-color-scheme. -->
<#macro emailLayout>
<!DOCTYPE html>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <style>
    .hl-body a { color: #3a6582; }
    @media (prefers-color-scheme: dark) {
      body, .hl-page { background-color: #0d1b2a !important; }
      .hl-rule { background-color: #d8b85e !important; }
      .hl-panel { background-color: #172433 !important; border-color: #25323f !important; }
      .hl-body, .hl-body p { color: #e8ecf0 !important; }
      .hl-body a { color: #6aa0b8 !important; }
      .hl-muted { color: #a0aab4 !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;background-color:#eef2f6;">
  <table role="presentation" class="hl-page" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#eef2f6;">
    <tr>
      <td align="center" style="padding:24px 12px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;">
          <tr>
            <td style="background-color:#0d1b2a;border-radius:16px 16px 0 0;padding:20px 24px;">
              <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="vertical-align:middle;padding-right:12px;color:#d8b85e;">
                    <svg class="hl-logo" width="30" height="36" viewBox="0 0 251 305" fill="none" stroke="none" aria-hidden="true" style="color:#d8b85e;display:block;">
                      <g transform="matrix(0.43,0,0,0.43,97.04,0.1)" fill="#d8b85e">
                        <path d="m 154.67,45.09 41.87,0 c 2.77,0 5,2.23 5,5 l 0,535.75 c 0,0 -0.48,28.81 -25.86,28.83 -26.03,0.02 -26.01,-28.83 -26.01,-28.83 l 0,-535.75 c 0,-2.77 2.23,-5 5,-5 z"/>
                        <path d="m 253.92,54.81 c 0,0 -167.87,0 -167.87,0 l 0,67.7 226.41,0 c 0,0 -24.51,-19.74 -58.54,-67.7 z"/>
                      </g>
                      <g transform="matrix(0.71,0,0,0.71,31.2,15.32)" fill="#d8b85e">
                        <path d="m 17.8,339.79 c 6.54,-66.47 7.74,-139.79 10.64,-210.28 1.02,-24.88 9.14,-26.41 15.7,-33.04 21.48,-16.84 31.37,-24.58 31.37,-24.58 0,0 0,-55.5 0,-55.5 0.31,-8.57 4.93,-12.32 9.1,-5.33 0,0 6,71.74 6,71.74 0,0 -25.22,19.84 -38.06,32.27 -7.49,5.95 -7.92,7.91 -8.15,16.96 -2.06,79.66 -5.1,152.34 -11.81,211.91 -3.84,11.53 -17.27,9.02 -14.79,-4.16 z"/>
                        <path transform="matrix(-1,0,0,1,108.93,0)" d="m 17.8,339.79 c 6.54,-66.47 7.74,-139.79 10.64,-210.28 1.02,-24.88 9.14,-26.41 15.7,-33.04 21.48,-16.84 31.37,-24.58 31.37,-24.58 0,0 0,-55.5 0,-55.5 0.31,-8.57 4.93,-12.32 9.1,-5.33 0,0 6,71.74 6,71.74 0,0 -25.22,19.84 -38.06,32.27 -7.49,5.95 -7.92,7.91 -8.15,16.96 -2.06,79.66 -5.1,152.34 -11.81,211.91 -3.84,11.53 -17.27,9.02 -14.79,-4.16 z"/>
                        <circle cx="54.47" cy="99.57" r="4.22"/>
                      </g>
                    </svg>
                  </td>
                  <td style="vertical-align:middle;font-family:Helvetica,Arial,sans-serif;font-size:16px;font-weight:700;color:#e8ecf0;">${realmName!''}</td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td class="hl-panel" style="background-color:#ffffff;border:1px solid #d5dde6;border-top:0;border-radius:0 0 16px 16px;padding:24px;">
              <div class="hl-rule" style="width:44px;height:3px;background-color:#7a5f10;border-radius:2px;margin:0 0 16px;line-height:3px;font-size:0;">&nbsp;</div>
              <div class="hl-body" style="font-family:Helvetica,Arial,sans-serif;font-size:15px;line-height:1.55;color:#0d1b2a;">
                <#nested>
              </div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>
