<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
        <title>Jenkins PipeLine Scripts</title>
        <style>:root
{
    --markdown-font-family: -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", system-ui, "Ubuntu", "Droid Sans", sans-serif;
    --markdown-font-size: 14px;
    --markdown-line-height: 1.6;
    --vscode-font-family:"Segoe WPC", "Segoe UI", sans-serif;
    --vscode-font-weight:normal;
    --vscode-font-size:13px;
    --vscode-editor-font-family:Consolas, "Courier New", monospace;
    --vscode-editor-font-weight:normal;
    --vscode-editor-font-size:14px;
    --vscode-foreground:#616161;
    --vscode-errorForeground:#a1260d;
    --vscode-descriptionForeground:#717171;
    --vscode-icon-foreground:#424242;
    --vscode-focusBorder:#0090f1;
    --vscode-textSeparator-foreground:rgba(0, 0, 0, 0.18);
    --vscode-textLink-foreground:#006ab1;
    --vscode-textLink-activeForeground:#006ab1;
    --vscode-textPreformat-foreground:#a31515;
    --vscode-textBlockQuote-background:rgba(127, 127, 127, 0.1);
    --vscode-textBlockQuote-border:rgba(0, 122, 204, 0.5);
    --vscode-textCodeBlock-background:rgba(220, 220, 220, 0.4);
    --vscode-widget-shadow:#a8a8a8;
    --vscode-input-background:#ffffff;
    --vscode-input-foreground:#616161;
    --vscode-inputOption-activeBorder:rgba(0, 122, 204, 0);
    --vscode-inputOption-activeBackground:rgba(0, 144, 241, 0.2);
    --vscode-inputOption-activeForeground:#000000;
    --vscode-input-placeholderForeground:#767676;
    --vscode-inputValidation-infoBackground:#d6ecf2;
    --vscode-inputValidation-infoBorder:#007acc;
    --vscode-inputValidation-warningBackground:#f6f5d2;
    --vscode-inputValidation-warningBorder:#b89500;
    --vscode-inputValidation-errorBackground:#f2dede;
    --vscode-inputValidation-errorBorder:#be1100;
    --vscode-dropdown-background:#ffffff;
    --vscode-dropdown-border:#cecece;
    --vscode-checkbox-background:#ffffff;
    --vscode-checkbox-border:#cecece;
    --vscode-button-foreground:#ffffff;
    --vscode-button-background:#007acc;
    --vscode-button-hoverBackground:#0062a3;
    --vscode-button-secondaryForeground:#ffffff;
    --vscode-button-secondaryBackground:#5f6a79;
    --vscode-button-secondaryHoverBackground:#4c5561;
    --vscode-badge-background:#c4c4c4;
    --vscode-badge-foreground:#333333;
    --vscode-scrollbar-shadow:#dddddd;
    --vscode-scrollbarSlider-background:rgba(100, 100, 100, 0.4);
    --vscode-scrollbarSlider-hoverBackground:rgba(100, 100, 100, 0.7);
    --vscode-scrollbarSlider-activeBackground:rgba(0, 0, 0, 0.6);
    --vscode-progressBar-background:#0e70c0;
    --vscode-editorError-foreground:#e51400;
    --vscode-editorWarning-foreground:#e9a700;
    --vscode-editorInfo-foreground:#75beff;
    --vscode-editorHint-foreground:#6c6c6c;
    --vscode-editor-background:#ffffff;
    --vscode-editor-foreground:#000000;
    --vscode-editorWidget-background:#f3f3f3;
    --vscode-editorWidget-foreground:#616161;
    --vscode-editorWidget-border:#c8c8c8;
    --vscode-quickInput-background:#f3f3f3;
    --vscode-quickInput-foreground:#616161;
    --vscode-quickInputTitle-background:rgba(0, 0, 0, 0.06);
    --vscode-pickerGroup-foreground:#0066bf;
    --vscode-pickerGroup-border:#cccedb;
    --vscode-editor-selectionBackground:#add6ff;
    --vscode-editor-inactiveSelectionBackground:#e5ebf1;
    --vscode-editor-selectionHighlightBackground:rgba(173, 214, 255, 0.5);
    --vscode-editor-findMatchBackground:#a8ac94;
    --vscode-editor-findMatchHighlightBackground:rgba(234, 92, 0, 0.33);
    --vscode-editor-findRangeHighlightBackground:rgba(180, 180, 180, 0.3);
    --vscode-searchEditor-findMatchBackground:rgba(234, 92, 0, 0.22);
    --vscode-editor-hoverHighlightBackground:rgba(173, 214, 255, 0.15);
    --vscode-editorHoverWidget-background:#f3f3f3;
    --vscode-editorHoverWidget-foreground:#616161;
    --vscode-editorHoverWidget-border:#c8c8c8;
    --vscode-editorHoverWidget-statusBarBackground:#e7e7e7;
    --vscode-editorLink-activeForeground:#0000ff;
    --vscode-editorLightBulb-foreground:#ddb100;
    --vscode-editorLightBulbAutoFix-foreground:#007acc;
    --vscode-diffEditor-insertedTextBackground:rgba(155, 185, 85, 0.2);
    --vscode-diffEditor-removedTextBackground:rgba(255, 0, 0, 0.2);
    --vscode-diffEditor-diagonalFill:rgba(34, 34, 34, 0.2);
    --vscode-list-focusBackground:#d6ebff;
    --vscode-list-activeSelectionBackground:#0074e8;
    --vscode-list-activeSelectionForeground:#ffffff;
    --vscode-list-inactiveSelectionBackground:#e4e6f1;
    --vscode-list-hoverBackground:#e8e8e8;
    --vscode-list-dropBackground:#d6ebff;
    --vscode-list-highlightForeground:#0066bf;
    --vscode-list-invalidItemForeground:#b89500;
    --vscode-list-errorForeground:#b01011;
    --vscode-list-warningForeground:#855f00;
    --vscode-listFilterWidget-background:#efc1ad;
    --vscode-listFilterWidget-outline:rgba(0, 0, 0, 0);
    --vscode-listFilterWidget-noMatchesOutline:#be1100;
    --vscode-list-filterMatchBackground:rgba(234, 92, 0, 0.33);
    --vscode-tree-indentGuidesStroke:#a9a9a9;
    --vscode-list-deemphasizedForeground:#8e8e90;
    --vscode-menu-foreground:#616161;
    --vscode-menu-background:#ffffff;
    --vscode-menu-selectionForeground:#ffffff;
    --vscode-menu-selectionBackground:#0074e8;
    --vscode-menu-separatorBackground:#888888;
    --vscode-editor-snippetTabstopHighlightBackground:rgba(10, 50, 100, 0.2);
    --vscode-editor-snippetFinalTabstopHighlightBorder:rgba(10, 50, 100, 0.5);
    --vscode-breadcrumb-foreground:rgba(97, 97, 97, 0.8);
    --vscode-breadcrumb-background:#ffffff;
    --vscode-breadcrumb-focusForeground:#4e4e4e;
    --vscode-breadcrumb-activeSelectionForeground:#4e4e4e;
    --vscode-breadcrumbPicker-background:#f3f3f3;
    --vscode-merge-currentHeaderBackground:rgba(64, 200, 174, 0.5);
    --vscode-merge-currentContentBackground:rgba(64, 200, 174, 0.2);
    --vscode-merge-incomingHeaderBackground:rgba(64, 166, 255, 0.5);
    --vscode-merge-incomingContentBackground:rgba(64, 166, 255, 0.2);
    --vscode-merge-commonHeaderBackground:rgba(96, 96, 96, 0.4);
    --vscode-merge-commonContentBackground:rgba(96, 96, 96, 0.16);
    --vscode-editorOverviewRuler-currentContentForeground:rgba(64, 200, 174, 0.5);
    --vscode-editorOverviewRuler-incomingContentForeground:rgba(64, 166, 255, 0.5);
    --vscode-editorOverviewRuler-commonContentForeground:rgba(96, 96, 96, 0.4);
    --vscode-editorOverviewRuler-findMatchForeground:rgba(209, 134, 22, 0.49);
    --vscode-editorOverviewRuler-selectionHighlightForeground:rgba(160, 160, 160, 0.8);
    --vscode-minimap-findMatchHighlight:#d18616;
    --vscode-minimap-selectionHighlight:#add6ff;
    --vscode-minimap-errorHighlight:rgba(255, 18, 18, 0.7);
    --vscode-minimap-warningHighlight:#e9a700;
    --vscode-minimapSlider-background:rgba(100, 100, 100, 0.2);
    --vscode-minimapSlider-hoverBackground:rgba(100, 100, 100, 0.35);
    --vscode-minimapSlider-activeBackground:rgba(0, 0, 0, 0.3);
    --vscode-problemsErrorIcon-foreground:#e51400;
    --vscode-problemsWarningIcon-foreground:#e9a700;
    --vscode-problemsInfoIcon-foreground:#75beff;
    --vscode-editor-lineHighlightBorder:#eeeeee;
    --vscode-editor-rangeHighlightBackground:rgba(253, 255, 0, 0.2);
    --vscode-editor-symbolHighlightBackground:rgba(234, 92, 0, 0.33);
    --vscode-editorCursor-foreground:#000000;
    --vscode-editorWhitespace-foreground:rgba(51, 51, 51, 0.2);
    --vscode-editorIndentGuide-background:#d3d3d3;
    --vscode-editorIndentGuide-activeBackground:#939393;
    --vscode-editorLineNumber-foreground:#237893;
    --vscode-editorActiveLineNumber-foreground:#0b216f;
    --vscode-editorLineNumber-activeForeground:#0b216f;
    --vscode-editorRuler-foreground:#d3d3d3;
    --vscode-editorCodeLens-foreground:#999999;
    --vscode-editorBracketMatch-background:rgba(0, 100, 0, 0.1);
    --vscode-editorBracketMatch-border:#b9b9b9;
    --vscode-editorOverviewRuler-border:rgba(127, 127, 127, 0.3);
    --vscode-editorGutter-background:#ffffff;
    --vscode-editorUnnecessaryCode-opacity:rgba(0, 0, 0, 0.47);
    --vscode-editorOverviewRuler-rangeHighlightForeground:rgba(0, 122, 204, 0.6);
    --vscode-editorOverviewRuler-errorForeground:rgba(255, 18, 18, 0.7);
    --vscode-editorOverviewRuler-warningForeground:#e9a700;
    --vscode-editorOverviewRuler-infoForeground:#75beff;
    --vscode-editorOverviewRuler-bracketMatchForeground:#a0a0a0;
    --vscode-symbolIcon-arrayForeground:#616161;
    --vscode-symbolIcon-booleanForeground:#616161;
    --vscode-symbolIcon-classForeground:#d67e00;
    --vscode-symbolIcon-colorForeground:#616161;
    --vscode-symbolIcon-constantForeground:#616161;
    --vscode-symbolIcon-constructorForeground:#652d90;
    --vscode-symbolIcon-enumeratorForeground:#d67e00;
    --vscode-symbolIcon-enumeratorMemberForeground:#007acc;
    --vscode-symbolIcon-eventForeground:#d67e00;
    --vscode-symbolIcon-fieldForeground:#007acc;
    --vscode-symbolIcon-fileForeground:#616161;
    --vscode-symbolIcon-folderForeground:#616161;
    --vscode-symbolIcon-functionForeground:#652d90;
    --vscode-symbolIcon-interfaceForeground:#007acc;
    --vscode-symbolIcon-keyForeground:#616161;
    --vscode-symbolIcon-keywordForeground:#616161;
    --vscode-symbolIcon-methodForeground:#652d90;
    --vscode-symbolIcon-moduleForeground:#616161;
    --vscode-symbolIcon-namespaceForeground:#616161;
    --vscode-symbolIcon-nullForeground:#616161;
    --vscode-symbolIcon-numberForeground:#616161;
    --vscode-symbolIcon-objectForeground:#616161;
    --vscode-symbolIcon-operatorForeground:#616161;
    --vscode-symbolIcon-packageForeground:#616161;
    --vscode-symbolIcon-propertyForeground:#616161;
    --vscode-symbolIcon-referenceForeground:#616161;
    --vscode-symbolIcon-snippetForeground:#616161;
    --vscode-symbolIcon-stringForeground:#616161;
    --vscode-symbolIcon-structForeground:#616161;
    --vscode-symbolIcon-textForeground:#616161;
    --vscode-symbolIcon-typeParameterForeground:#616161;
    --vscode-symbolIcon-unitForeground:#616161;
    --vscode-symbolIcon-variableForeground:#007acc;
    --vscode-editor-foldBackground:rgba(173, 214, 255, 0.3);
    --vscode-editorGutter-foldingControlForeground:#424242;
    --vscode-editor-onTypeRenameBackground:rgba(255, 0, 0, 0.3);
    --vscode-editorSuggestWidget-background:#f3f3f3;
    --vscode-editorSuggestWidget-border:#c8c8c8;
    --vscode-editorSuggestWidget-foreground:#000000;
    --vscode-editorSuggestWidget-selectedBackground:#d6ebff;
    --vscode-editorSuggestWidget-highlightForeground:#0066bf;
    --vscode-editor-wordHighlightBackground:rgba(87, 87, 87, 0.25);
    --vscode-editor-wordHighlightStrongBackground:rgba(14, 99, 156, 0.25);
    --vscode-editorOverviewRuler-wordHighlightForeground:rgba(160, 160, 160, 0.8);
    --vscode-editorOverviewRuler-wordHighlightStrongForeground:rgba(192, 160, 192, 0.8);
    --vscode-peekViewTitle-background:#ffffff;
    --vscode-peekViewTitleLabel-foreground:#333333;
    --vscode-peekViewTitleDescription-foreground:rgba(97, 97, 97, 0.9);
    --vscode-peekView-border:#007acc;
    --vscode-peekViewResult-background:#f3f3f3;
    --vscode-peekViewResult-lineForeground:#646465;
    --vscode-peekViewResult-fileForeground:#1e1e1e;
    --vscode-peekViewResult-selectionBackground:rgba(51, 153, 255, 0.2);
    --vscode-peekViewResult-selectionForeground:#6c6c6c;
    --vscode-peekViewEditor-background:#f2f8fc;
    --vscode-peekViewEditorGutter-background:#f2f8fc;
    --vscode-peekViewResult-matchHighlightBackground:rgba(234, 92, 0, 0.3);
    --vscode-peekViewEditor-matchHighlightBackground:rgba(245, 216, 2, 0.87);
    --vscode-editorMarkerNavigationError-background:#e51400;
    --vscode-editorMarkerNavigationWarning-background:#e9a700;
    --vscode-editorMarkerNavigationInfo-background:#75beff;
    --vscode-editorMarkerNavigation-background:#ffffff;
    --vscode-tab-activeBackground:#ffffff;
    --vscode-tab-unfocusedActiveBackground:#ffffff;
    --vscode-tab-inactiveBackground:#ececec;
    --vscode-tab-unfocusedInactiveBackground:#ececec;
    --vscode-tab-activeForeground:#333333;
    --vscode-tab-inactiveForeground:rgba(51, 51, 51, 0.7);
    --vscode-tab-unfocusedActiveForeground:rgba(51, 51, 51, 0.7);
    --vscode-tab-unfocusedInactiveForeground:rgba(51, 51, 51, 0.35);
    --vscode-tab-activeModifiedBorder:#33aaee;
    --vscode-tab-inactiveModifiedBorder:rgba(51, 170, 238, 0.5);
    --vscode-tab-unfocusedActiveModifiedBorder:rgba(51, 170, 238, 0.7);
    --vscode-tab-unfocusedInactiveModifiedBorder:rgba(51, 170, 238, 0.25);
    --vscode-tab-border:#f3f3f3;
    --vscode-editorPane-background:#ffffff;
    --vscode-editorGroupHeader-tabsBackground:#f3f3f3;
    --vscode-editorGroupHeader-noTabsBackground:#ffffff;
    --vscode-editorGroup-border:#e7e7e7;
    --vscode-editorGroup-dropBackground:rgba(38, 119, 203, 0.18);
    --vscode-imagePreview-border:rgba(128, 128, 128, 0.35);
    --vscode-panel-background:#ffffff;
    --vscode-panel-border:rgba(128, 128, 128, 0.35);
    --vscode-panelTitle-activeForeground:#424242;
    --vscode-panelTitle-inactiveForeground:rgba(66, 66, 66, 0.75);
    --vscode-panelTitle-activeBorder:#424242;
    --vscode-panelInput-border:#dddddd;
    --vscode-panel-dropBorder:#424242;
    --vscode-panelSection-dropBackground:rgba(38, 119, 203, 0.18);
    --vscode-panelSectionHeader-background:rgba(128, 128, 128, 0.2);
    --vscode-panelSection-border:rgba(128, 128, 128, 0.35);
    --vscode-statusBar-foreground:#ffffff;
    --vscode-statusBar-noFolderForeground:#ffffff;
    --vscode-statusBar-background:#007acc;
    --vscode-statusBar-noFolderBackground:#68217a;
    --vscode-statusBarItem-activeBackground:rgba(255, 255, 255, 0.18);
    --vscode-statusBarItem-hoverBackground:rgba(255, 255, 255, 0.12);
    --vscode-statusBarItem-prominentForeground:#ffffff;
    --vscode-statusBarItem-prominentBackground:rgba(0, 0, 0, 0.5);
    --vscode-statusBarItem-prominentHoverBackground:rgba(0, 0, 0, 0.3);
    --vscode-activityBar-background:#2c2c2c;
    --vscode-activityBar-foreground:#ffffff;
    --vscode-activityBar-inactiveForeground:rgba(255, 255, 255, 0.4);
    --vscode-activityBar-activeBorder:#ffffff;
    --vscode-activityBar-dropBorder:#ffffff;
    --vscode-activityBarBadge-background:#007acc;
    --vscode-activityBarBadge-foreground:#ffffff;
    --vscode-statusBarItem-remoteBackground:#16825d;
    --vscode-statusBarItem-remoteForeground:#ffffff;
    --vscode-extensionBadge-remoteBackground:#007acc;
    --vscode-extensionBadge-remoteForeground:#ffffff;
    --vscode-sideBar-background:#f3f3f3;
    --vscode-sideBarTitle-foreground:#6f6f6f;
    --vscode-sideBar-dropBackground:rgba(38, 119, 203, 0.18);
    --vscode-sideBarSectionHeader-background:rgba(0, 0, 0, 0);
    --vscode-sideBarSectionHeader-border:rgba(97, 97, 97, 0.19);
    --vscode-titleBar-activeForeground:#333333;
    --vscode-titleBar-inactiveForeground:rgba(51, 51, 51, 0.6);
    --vscode-titleBar-activeBackground:#dddddd;
    --vscode-titleBar-inactiveBackground:rgba(221, 221, 221, 0.6);
    --vscode-menubar-selectionForeground:#333333;
    --vscode-menubar-selectionBackground:rgba(0, 0, 0, 0.1);
    --vscode-notifications-foreground:#616161;
    --vscode-notifications-background:#f3f3f3;
    --vscode-notificationLink-foreground:#006ab1;
    --vscode-notificationCenterHeader-background:#e7e7e7;
    --vscode-notifications-border:#e7e7e7;
    --vscode-notificationsErrorIcon-foreground:#e51400;
    --vscode-notificationsWarningIcon-foreground:#e9a700;
    --vscode-notificationsInfoIcon-foreground:#75beff;
    --vscode-editorGutter-commentRangeForeground:#c5c5c5;
    --vscode-editor-stackFrameHighlightBackground:rgba(255, 255, 102, 0.45);
    --vscode-editor-focusedStackFrameHighlightBackground:rgba(206, 231, 206, 0.45);
    --vscode-terminal-foreground:#333333;
    --vscode-terminal-selectionBackground:rgba(0, 0, 0, 0.25);
    --vscode-terminal-border:rgba(128, 128, 128, 0.35);
    --vscode-statusBar-debuggingBackground:#cc6633;
    --vscode-statusBar-debuggingForeground:#ffffff;
    --vscode-settings-headerForeground:#444444;
    --vscode-settings-modifiedItemIndicator:#66afe0;
    --vscode-settings-dropdownBackground:#ffffff;
    --vscode-settings-dropdownBorder:#cecece;
    --vscode-settings-dropdownListBorder:#c8c8c8;
    --vscode-settings-checkboxBackground:#ffffff;
    --vscode-settings-checkboxBorder:#cecece;
    --vscode-settings-textInputBackground:#ffffff;
    --vscode-settings-textInputForeground:#616161;
    --vscode-settings-textInputBorder:#cecece;
    --vscode-settings-numberInputBackground:#ffffff;
    --vscode-settings-numberInputForeground:#616161;
    --vscode-settings-numberInputBorder:#cecece;
    --vscode-debugExceptionWidget-border:#a31515;
    --vscode-debugExceptionWidget-background:#f1dfde;
    --vscode-editorGutter-modifiedBackground:#66afe0;
    --vscode-editorGutter-addedBackground:#81b88b;
    --vscode-editorGutter-deletedBackground:#ca4b51;
    --vscode-minimapGutter-modifiedBackground:#66afe0;
    --vscode-minimapGutter-addedBackground:#81b88b;
    --vscode-minimapGutter-deletedBackground:#ca4b51;
    --vscode-editorOverviewRuler-modifiedForeground:rgba(102, 175, 224, 0.6);
    --vscode-editorOverviewRuler-addedForeground:rgba(129, 184, 139, 0.6);
    --vscode-editorOverviewRuler-deletedForeground:rgba(202, 75, 81, 0.6);
    --vscode-searchEditor-textInputBorder:#cecece;
    --vscode-debugIcon-breakpointForeground:#e51400;
    --vscode-debugIcon-breakpointDisabledForeground:#848484;
    --vscode-debugIcon-breakpointUnverifiedForeground:#848484;
    --vscode-debugIcon-breakpointCurrentStackframeForeground:#ffcc00;
    --vscode-debugIcon-breakpointStackframeForeground:#89d185;
    --vscode-debugToolBar-background:#f3f3f3;
    --vscode-debugIcon-startForeground:#388a34;
    --vscode-debugIcon-pauseForeground:#007acc;
    --vscode-debugIcon-stopForeground:#a1260d;
    --vscode-debugIcon-disconnectForeground:#a1260d;
    --vscode-debugIcon-restartForeground:#388a34;
    --vscode-debugIcon-stepOverForeground:#007acc;
    --vscode-debugIcon-stepIntoForeground:#007acc;
    --vscode-debugIcon-stepOutForeground:#007acc;
    --vscode-debugIcon-continueForeground:#007acc;
    --vscode-debugIcon-stepBackForeground:#007acc;
    --vscode-debugTokenExpression-name:#9b46b0;
    --vscode-debugTokenExpression-value:rgba(108, 108, 108, 0.8);
    --vscode-debugTokenExpression-string:#a31515;
    --vscode-debugTokenExpression-boolean:#0000ff;
    --vscode-debugTokenExpression-number:#098658;
    --vscode-debugTokenExpression-error:#e51400;
    --vscode-debugView-exceptionLabelForeground:#ffffff;
    --vscode-debugView-exceptionLabelBackground:#a31515;
    --vscode-debugView-stateLabelForeground:#616161;
    --vscode-debugView-stateLabelBackground:rgba(136, 136, 136, 0.27);
    --vscode-debugView-valueChangedHighlight:#569cd6;
    --vscode-debugConsole-infoForeground:#75beff;
    --vscode-debugConsole-warningForeground:#e9a700;
    --vscode-debugConsole-errorForeground:#a1260d;
    --vscode-debugConsole-sourceForeground:#616161;
    --vscode-debugConsoleInputIcon-foreground:#616161;
    --vscode-extensionButton-prominentBackground:#327e36;
    --vscode-extensionButton-prominentForeground:#ffffff;
    --vscode-extensionButton-prominentHoverBackground:#28632b;
    --vscode-notebook-cellBorderColor:#dae3e9;
    --vscode-notebook-focusedEditorBorder:#0090f1;
    --vscode-notebookStatusSuccessIcon-foreground:#388a34;
    --vscode-notebookStatusErrorIcon-foreground:#a1260d;
    --vscode-notebookStatusRunningIcon-foreground:#616161;
    --vscode-notebook-outputContainerBackgroundColor:rgba(200, 221, 241, 0.31);
    --vscode-notebook-cellToolbarSeparator:rgba(128, 128, 128, 0.35);
    --vscode-notebook-focusedCellBackground:rgba(200, 221, 241, 0.31);
    --vscode-notebook-cellHoverBackground:rgba(200, 221, 241, 0.22);
    --vscode-notebook-focusedCellBorder:rgba(0, 0, 0, 0.12);
    --vscode-notebook-cellStatusBarItemHoverBackground:rgba(0, 0, 0, 0.08);
    --vscode-notebook-cellInsertionIndicator:#0090f1;
    --vscode-notebookScrollbarSlider-background:rgba(100, 100, 100, 0.4);
    --vscode-notebookScrollbarSlider-hoverBackground:rgba(100, 100, 100, 0.7);
    --vscode-notebookScrollbarSlider-activeBackground:rgba(0, 0, 0, 0.6);
    --vscode-notebook-symbolHighlightBackground:rgba(253, 255, 0, 0.2);
    --vscode-scm-providerBorder:#c8c8c8;
    --vscode-terminal-ansiBlack:#000000;
    --vscode-terminal-ansiRed:#cd3131;
    --vscode-terminal-ansiGreen:#00bc00;
    --vscode-terminal-ansiYellow:#949800;
    --vscode-terminal-ansiBlue:#0451a5;
    --vscode-terminal-ansiMagenta:#bc05bc;
    --vscode-terminal-ansiCyan:#0598bc;
    --vscode-terminal-ansiWhite:#555555;
    --vscode-terminal-ansiBrightBlack:#666666;
    --vscode-terminal-ansiBrightRed:#cd3131;
    --vscode-terminal-ansiBrightGreen:#14ce14;
    --vscode-terminal-ansiBrightYellow:#b5ba00;
    --vscode-terminal-ansiBrightBlue:#0451a5;
    --vscode-terminal-ansiBrightMagenta:#bc05bc;
    --vscode-terminal-ansiBrightCyan:#0598bc;
    --vscode-terminal-ansiBrightWhite:#a5a5a5;
    --vscode-gitDecoration-addedResourceForeground:#587c0c;
    --vscode-gitDecoration-modifiedResourceForeground:#895503;
    --vscode-gitDecoration-deletedResourceForeground:#ad0707;
    --vscode-gitDecoration-untrackedResourceForeground:#007100;
    --vscode-gitDecoration-ignoredResourceForeground:#8e8e90;
    --vscode-gitDecoration-conflictingResourceForeground:#6c6cc4;
    --vscode-gitDecoration-submoduleResourceForeground:#1258a7;
    --vscode-gitlens-gutterBackgroundColor:rgba(0, 0, 0, 0.05);
    --vscode-gitlens-gutterForegroundColor:#747474;
    --vscode-gitlens-gutterUncommittedForegroundColor:rgba(0, 188, 242, 0.6);
    --vscode-gitlens-trailingLineBackgroundColor:rgba(0, 0, 0, 0);
    --vscode-gitlens-trailingLineForegroundColor:rgba(153, 153, 153, 0.35);
    --vscode-gitlens-lineHighlightBackgroundColor:rgba(0, 188, 242, 0.2);
    --vscode-gitlens-lineHighlightOverviewRulerColor:rgba(0, 188, 242, 0.6);
    --vscode-issues-newIssueDecoration:rgba(0, 0, 0, 0.28);
}

body
{
    background-color: var(--vscode-editor-background);
    color: var(--vscode-editor-foreground);
    font-family: var(--vscode-font-family);
    font-weight: var(--vscode-font-weight);
    font-size: var(--vscode-font-size);
    margin: 0;
    padding: 0 20px;
}

img
{
    max-width: 100%;
    max-height: 100%;
}

a
{
    color: var(--vscode-textLink-foreground);
}

a:hover
{
    color: var(--vscode-textLink-activeForeground);
}

a:focus,
input:focus,
select:focus,
textarea:focus
{
    outline: 1px solid -webkit-focus-ring-color;
    outline-offset: -1px;
}

code
{
    color: var(--vscode-textPreformat-foreground);
}

blockquote
{
    background: var(--vscode-textBlockQuote-background);
    border-color: var(--vscode-textBlockQuote-border);
}

kbd
{
    color: var(--vscode-editor-foreground);
    border-radius: 3px;
    vertical-align: middle;
    padding: 1px 3px;

    background-color: hsla(0,0%,50%,.17);
    border: 1px solid rgba(71,71,71,.4);
    border-bottom-color: rgba(88,88,88,.4);
    box-shadow: inset 0 -1px 0 rgba(88,88,88,.4);
}

.vscode-light kbd
{
    background-color: hsla(0,0%,87%,.5);
    border: 1px solid hsla(0,0%,80%,.7);
    border-bottom-color: hsla(0,0%,73%,.7);
    box-shadow: inset 0 -1px 0 hsla(0,0%,73%,.7);
}

::-webkit-scrollbar
{
    width: 10px;
    height: 10px;
}

::-webkit-scrollbar-corner
{
    background-color: var(--vscode-editor-background);
}

::-webkit-scrollbar-thumb
{
    background-color: var(--vscode-scrollbarSlider-background);
}
::-webkit-scrollbar-thumb:hover
{
    background-color: var(--vscode-scrollbarSlider-hoverBackground);
}
::-webkit-scrollbar-thumb:active
{
    background-color: var(--vscode-scrollbarSlider-activeBackground);
}

.emoji
{
    height: 20px;
}

pre
{
    white-space: pre-wrap;
}

.page-break
{
    display: block;
    page-break-after: always;
}

.no-page-break
{
    page-break-inside: avoid;
}
</style>
<style>/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

.vscode-dark img[src$=\#gh-light-mode-only],
.vscode-light img[src$=\#gh-dark-mode-only] {
	display: none;
}
</style>
<style>/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

html, body {
	font-family: var(--markdown-font-family, -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", system-ui, "Ubuntu", "Droid Sans", sans-serif);
	font-size: var(--markdown-font-size, 14px);
	padding: 0 26px;
	line-height: var(--markdown-line-height, 22px);
	word-wrap: break-word;
}

body {
	padding-top: 1em;
}

/* Reset margin top for elements */
h1, h2, h3, h4, h5, h6,
p, ol, ul, pre {
	margin-top: 0;
}

h1, h2, h3, h4, h5, h6 {
	font-weight: 600;
	margin-top: 24px;
	margin-bottom: 16px;
	line-height: 1.25;
}

#code-csp-warning {
	position: fixed;
	top: 0;
	right: 0;
	color: white;
	margin: 16px;
	text-align: center;
	font-size: 12px;
	font-family: sans-serif;
	background-color:#444444;
	cursor: pointer;
	padding: 6px;
	box-shadow: 1px 1px 1px rgba(0,0,0,.25);
}

#code-csp-warning:hover {
	text-decoration: none;
	background-color:#007acc;
	box-shadow: 2px 2px 2px rgba(0,0,0,.25);
}

body.scrollBeyondLastLine {
	margin-bottom: calc(100vh - 22px);
}

body.showEditorSelection .code-line {
	position: relative;
}

body.showEditorSelection :not(tr,ul,ol).code-active-line:before,
body.showEditorSelection :not(tr,ul,ol).code-line:hover:before {
	content: "";
	display: block;
	position: absolute;
	top: 0;
	left: -12px;
	height: 100%;
}

.vscode-high-contrast.showEditorSelection  :not(tr,ul,ol).code-line .code-line:hover:before {
	border-left: none;
}

body.showEditorSelection li.code-active-line:before,
body.showEditorSelection li.code-line:hover:before {
	left: -30px;
}

.vscode-light.showEditorSelection .code-active-line:before {
	border-left: 3px solid rgba(0, 0, 0, 0.15);
}

.vscode-light.showEditorSelection .code-line:hover:before {
	border-left: 3px solid rgba(0, 0, 0, 0.40);
}

.vscode-dark.showEditorSelection .code-active-line:before {
	border-left: 3px solid rgba(255, 255, 255, 0.4);
}

.vscode-dark.showEditorSelection .code-line:hover:before {
	border-left: 3px solid rgba(255, 255, 255, 0.60);
}

.vscode-high-contrast.showEditorSelection .code-active-line:before {
	border-left: 3px solid rgba(255, 160, 0, 0.7);
}

.vscode-high-contrast.showEditorSelection .code-line:hover:before {
	border-left: 3px solid rgba(255, 160, 0, 1);
}

/* Prevent `sub` and `sup` elements from affecting line height */
sub,
sup {
	line-height: 0;
}

ul ul,
ul ol,
ol ul,
ol ol {
	margin-bottom: 0;
}

img, video {
	max-width: 100%;
	max-height: 100%;
}

a {
	text-decoration: none;
}

a:hover {
	text-decoration: underline;
}

a:focus,
input:focus,
select:focus,
textarea:focus {
	outline: 1px solid -webkit-focus-ring-color;
	outline-offset: -1px;
}

p {
	margin-bottom: 16px;
}

ul,
ol {
	margin-bottom: 0.7em;
}

hr {
	border: 0;
	height: 1px;
	border-bottom: 1px solid;
}

h1 {
	font-size: 2em;
	margin-top: 0;
	padding-bottom: 0.3em;
	border-bottom-width: 1px;
	border-bottom-style: solid;
}

h2 {
	font-size: 1.5em;
	padding-bottom: 0.3em;
	border-bottom-width: 1px;
	border-bottom-style: solid;
}

h3 {
	font-size: 1.25em;
}

h4 {
	font-size: 1em;
}

h5 {
	font-size: 0.875em;
}

h6 {
	font-size: 0.85em;
}

table {
	border-collapse: collapse;
	margin-bottom: 0.7em;
}

th {
	text-align: left;
	border-bottom: 1px solid;
}

th,
td {
	padding: 5px 10px;
}

table > tbody > tr + tr > td {
	border-top: 1px solid;
}

blockquote {
	margin: 0 7px 0 5px;
	padding: 0 16px 0 10px;
	border-left-width: 5px;
	border-left-style: solid;
}

code {
	font-family: var(--vscode-editor-font-family, "SF Mono", Monaco, Menlo, Consolas, "Ubuntu Mono", "Liberation Mono", "DejaVu Sans Mono", "Courier New", monospace);
	font-size: 1em;
	line-height: 1.357em;
}

body.wordWrap pre {
	white-space: pre-wrap;
}

pre:not(.hljs),
pre.hljs code > div {
	padding: 16px;
	border-radius: 3px;
	overflow: auto;
}

pre code {
	color: var(--vscode-editor-foreground);
	tab-size: 4;
}

/** Theming */

pre {
	background-color: var(--vscode-textCodeBlock-background);
}

.vscode-high-contrast h1 {
	border-color: rgb(0, 0, 0);
}

.vscode-light th {
	border-color: rgba(0, 0, 0, 0.69);
}

.vscode-dark th {
	border-color: rgba(255, 255, 255, 0.69);
}

.vscode-light h1,
.vscode-light h2,
.vscode-light hr,
.vscode-light td {
	border-color: rgba(0, 0, 0, 0.18);
}

.vscode-dark h1,
.vscode-dark h2,
.vscode-dark hr,
.vscode-dark td {
	border-color: rgba(255, 255, 255, 0.18);
}
</style>
<style>/*
https://raw.githubusercontent.com/isagalaev/highlight.js/master/src/styles/vs2015.css
*/
/*
 * Visual Studio 2015 dark style
 * Author: Nicolas LLOBERA <nllobera@gmail.com>
 */


.hljs-keyword,
.hljs-literal,
.hljs-symbol,
.hljs-name {
	color: #569CD6;
}
.hljs-link {
	color: #569CD6;
	text-decoration: underline;
}

.hljs-built_in,
.hljs-type {
	color: #4EC9B0;
}

.hljs-number,
.hljs-class {
	color: #B8D7A3;
}

.hljs-string,
.hljs-meta-string {
	color: #D69D85;
}

.hljs-regexp,
.hljs-template-tag {
	color: #9A5334;
}

.hljs-subst,
.hljs-function,
.hljs-title,
.hljs-params,
.hljs-formula {
	color: #DCDCDC;
}

.hljs-comment,
.hljs-quote {
	color: #57A64A;
	font-style: italic;
}

.hljs-doctag {
	color: #608B4E;
}

.hljs-meta,
.hljs-meta-keyword,
.hljs-tag {
	color: #9B9B9B;
}

.hljs-variable,
.hljs-template-variable {
	color: #BD63C5;
}

.hljs-attr,
.hljs-attribute,
.hljs-builtin-name {
	color: #9CDCFE;
}

.hljs-section {
	color: gold;
}

.hljs-emphasis {
	font-style: italic;
}

.hljs-strong {
	font-weight: bold;
}

/*.hljs-code {
	font-family:'Monospace';
}*/

.hljs-bullet,
.hljs-selector-tag,
.hljs-selector-id,
.hljs-selector-class,
.hljs-selector-attr,
.hljs-selector-pseudo {
	color: #D7BA7D;
}

.hljs-addition {
	background-color: var(--vscode-diffEditor-insertedTextBackground, rgba(155, 185, 85, 0.2));
	color: rgb(155, 185, 85);
	display: inline-block;
	width: 100%;
}

.hljs-deletion {
	background: var(--vscode-diffEditor-removedTextBackground, rgba(255, 0, 0, 0.2));
	color: rgb(255, 0, 0);
	display: inline-block;
	width: 100%;
}


/*
From https://raw.githubusercontent.com/isagalaev/highlight.js/master/src/styles/vs.css
*/
/*

Visual Studio-like style based on original C# coloring by Jason Diamond <jason@diamond.name>

*/

.vscode-light .hljs-function,
.vscode-light .hljs-params,
.vscode-light .hljs-number,
.vscode-light .hljs-class  {
	color: inherit;
}

.vscode-light .hljs-comment,
.vscode-light .hljs-quote,
.vscode-light .hljs-number,
.vscode-light .hljs-class,
.vscode-light .hljs-variable {
	color: #008000;
}

.vscode-light .hljs-keyword,
.vscode-light .hljs-selector-tag,
.vscode-light .hljs-name,
.vscode-light .hljs-tag {
	color: #00f;
}

.vscode-light .hljs-built_in,
.vscode-light .hljs-builtin-name {
	color: #007acc;
}

.vscode-light .hljs-string,
.vscode-light .hljs-section,
.vscode-light .hljs-attribute,
.vscode-light .hljs-literal,
.vscode-light .hljs-template-tag,
.vscode-light .hljs-template-variable,
.vscode-light .hljs-type {
	color: #a31515;
}

.vscode-light .hljs-selector-attr,
.vscode-light .hljs-selector-pseudo,
.vscode-light .hljs-meta,
.vscode-light .hljs-meta-keyword {
	color: #2b91af;
}

.vscode-light .hljs-title,
.vscode-light .hljs-doctag {
	color: #808080;
}

.vscode-light .hljs-attr {
	color: #f00;
}

.vscode-light .hljs-symbol,
.vscode-light .hljs-bullet,
.vscode-light .hljs-link {
	color: #00b0e8;
}


.vscode-light .hljs-emphasis {
	font-style: italic;
}

.vscode-light .hljs-strong {
	font-weight: bold;
}
</style>
<style>@font-face{font-family:KaTeX_AMS;font-style:normal;font-weight:400;src:url(fonts/KaTeX_AMS-Regular.woff2) format("woff2"),url(fonts/KaTeX_AMS-Regular.woff) format("woff"),url(fonts/KaTeX_AMS-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Caligraphic;font-style:normal;font-weight:700;src:url(fonts/KaTeX_Caligraphic-Bold.woff2) format("woff2"),url(fonts/KaTeX_Caligraphic-Bold.woff) format("woff"),url(fonts/KaTeX_Caligraphic-Bold.ttf) format("truetype")}@font-face{font-family:KaTeX_Caligraphic;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Caligraphic-Regular.woff2) format("woff2"),url(fonts/KaTeX_Caligraphic-Regular.woff) format("woff"),url(fonts/KaTeX_Caligraphic-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Fraktur;font-style:normal;font-weight:700;src:url(fonts/KaTeX_Fraktur-Bold.woff2) format("woff2"),url(fonts/KaTeX_Fraktur-Bold.woff) format("woff"),url(fonts/KaTeX_Fraktur-Bold.ttf) format("truetype")}@font-face{font-family:KaTeX_Fraktur;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Fraktur-Regular.woff2) format("woff2"),url(fonts/KaTeX_Fraktur-Regular.woff) format("woff"),url(fonts/KaTeX_Fraktur-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Main;font-style:normal;font-weight:700;src:url(fonts/KaTeX_Main-Bold.woff2) format("woff2"),url(fonts/KaTeX_Main-Bold.woff) format("woff"),url(fonts/KaTeX_Main-Bold.ttf) format("truetype")}@font-face{font-family:KaTeX_Main;font-style:italic;font-weight:700;src:url(fonts/KaTeX_Main-BoldItalic.woff2) format("woff2"),url(fonts/KaTeX_Main-BoldItalic.woff) format("woff"),url(fonts/KaTeX_Main-BoldItalic.ttf) format("truetype")}@font-face{font-family:KaTeX_Main;font-style:italic;font-weight:400;src:url(fonts/KaTeX_Main-Italic.woff2) format("woff2"),url(fonts/KaTeX_Main-Italic.woff) format("woff"),url(fonts/KaTeX_Main-Italic.ttf) format("truetype")}@font-face{font-family:KaTeX_Main;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Main-Regular.woff2) format("woff2"),url(fonts/KaTeX_Main-Regular.woff) format("woff"),url(fonts/KaTeX_Main-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Math;font-style:italic;font-weight:700;src:url(fonts/KaTeX_Math-BoldItalic.woff2) format("woff2"),url(fonts/KaTeX_Math-BoldItalic.woff) format("woff"),url(fonts/KaTeX_Math-BoldItalic.ttf) format("truetype")}@font-face{font-family:KaTeX_Math;font-style:italic;font-weight:400;src:url(fonts/KaTeX_Math-Italic.woff2) format("woff2"),url(fonts/KaTeX_Math-Italic.woff) format("woff"),url(fonts/KaTeX_Math-Italic.ttf) format("truetype")}@font-face{font-family:"KaTeX_SansSerif";font-style:normal;font-weight:700;src:url(fonts/KaTeX_SansSerif-Bold.woff2) format("woff2"),url(fonts/KaTeX_SansSerif-Bold.woff) format("woff"),url(fonts/KaTeX_SansSerif-Bold.ttf) format("truetype")}@font-face{font-family:"KaTeX_SansSerif";font-style:italic;font-weight:400;src:url(fonts/KaTeX_SansSerif-Italic.woff2) format("woff2"),url(fonts/KaTeX_SansSerif-Italic.woff) format("woff"),url(fonts/KaTeX_SansSerif-Italic.ttf) format("truetype")}@font-face{font-family:"KaTeX_SansSerif";font-style:normal;font-weight:400;src:url(fonts/KaTeX_SansSerif-Regular.woff2) format("woff2"),url(fonts/KaTeX_SansSerif-Regular.woff) format("woff"),url(fonts/KaTeX_SansSerif-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Script;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Script-Regular.woff2) format("woff2"),url(fonts/KaTeX_Script-Regular.woff) format("woff"),url(fonts/KaTeX_Script-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Size1;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Size1-Regular.woff2) format("woff2"),url(fonts/KaTeX_Size1-Regular.woff) format("woff"),url(fonts/KaTeX_Size1-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Size2;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Size2-Regular.woff2) format("woff2"),url(fonts/KaTeX_Size2-Regular.woff) format("woff"),url(fonts/KaTeX_Size2-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Size3;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Size3-Regular.woff2) format("woff2"),url(fonts/KaTeX_Size3-Regular.woff) format("woff"),url(fonts/KaTeX_Size3-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Size4;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Size4-Regular.woff2) format("woff2"),url(fonts/KaTeX_Size4-Regular.woff) format("woff"),url(fonts/KaTeX_Size4-Regular.ttf) format("truetype")}@font-face{font-family:KaTeX_Typewriter;font-style:normal;font-weight:400;src:url(fonts/KaTeX_Typewriter-Regular.woff2) format("woff2"),url(fonts/KaTeX_Typewriter-Regular.woff) format("woff"),url(fonts/KaTeX_Typewriter-Regular.ttf) format("truetype")}.katex{text-rendering:auto;font:normal 1.21em KaTeX_Main,Times New Roman,serif;line-height:1.2;text-indent:0}.katex *{-ms-high-contrast-adjust:none!important;border-color:currentColor}.katex .katex-version:after{content:"0.16.4"}.katex .katex-mathml{clip:rect(1px,1px,1px,1px);border:0;height:1px;overflow:hidden;padding:0;position:absolute;width:1px}.katex .katex-html>.newline{display:block}.katex .base{position:relative;white-space:nowrap;width:-webkit-min-content;width:-moz-min-content;width:min-content}.katex .base,.katex .strut{display:inline-block}.katex .textbf{font-weight:700}.katex .textit{font-style:italic}.katex .textrm{font-family:KaTeX_Main}.katex .textsf{font-family:KaTeX_SansSerif}.katex .texttt{font-family:KaTeX_Typewriter}.katex .mathnormal{font-family:KaTeX_Math;font-style:italic}.katex .mathit{font-family:KaTeX_Main;font-style:italic}.katex .mathrm{font-style:normal}.katex .mathbf{font-family:KaTeX_Main;font-weight:700}.katex .boldsymbol{font-family:KaTeX_Math;font-style:italic;font-weight:700}.katex .amsrm,.katex .mathbb,.katex .textbb{font-family:KaTeX_AMS}.katex .mathcal{font-family:KaTeX_Caligraphic}.katex .mathfrak,.katex .textfrak{font-family:KaTeX_Fraktur}.katex .mathtt{font-family:KaTeX_Typewriter}.katex .mathscr,.katex .textscr{font-family:KaTeX_Script}.katex .mathsf,.katex .textsf{font-family:KaTeX_SansSerif}.katex .mathboldsf,.katex .textboldsf{font-family:KaTeX_SansSerif;font-weight:700}.katex .mathitsf,.katex .textitsf{font-family:KaTeX_SansSerif;font-style:italic}.katex .mainrm{font-family:KaTeX_Main;font-style:normal}.katex .vlist-t{border-collapse:collapse;display:inline-table;table-layout:fixed}.katex .vlist-r{display:table-row}.katex .vlist{display:table-cell;position:relative;vertical-align:bottom}.katex .vlist>span{display:block;height:0;position:relative}.katex .vlist>span>span{display:inline-block}.katex .vlist>span>.pstrut{overflow:hidden;width:0}.katex .vlist-t2{margin-right:-2px}.katex .vlist-s{display:table-cell;font-size:1px;min-width:2px;vertical-align:bottom;width:2px}.katex .vbox{align-items:baseline;display:inline-flex;flex-direction:column}.katex .hbox{width:100%}.katex .hbox,.katex .thinbox{display:inline-flex;flex-direction:row}.katex .thinbox{max-width:0;width:0}.katex .msupsub{text-align:left}.katex .mfrac>span>span{text-align:center}.katex .mfrac .frac-line{border-bottom-style:solid;display:inline-block;width:100%}.katex .hdashline,.katex .hline,.katex .mfrac .frac-line,.katex .overline .overline-line,.katex .rule,.katex .underline .underline-line{min-height:1px}.katex .mspace{display:inline-block}.katex .clap,.katex .llap,.katex .rlap{position:relative;width:0}.katex .clap>.inner,.katex .llap>.inner,.katex .rlap>.inner{position:absolute}.katex .clap>.fix,.katex .llap>.fix,.katex .rlap>.fix{display:inline-block}.katex .llap>.inner{right:0}.katex .clap>.inner,.katex .rlap>.inner{left:0}.katex .clap>.inner>span{margin-left:-50%;margin-right:50%}.katex .rule{border:0 solid;display:inline-block;position:relative}.katex .hline,.katex .overline .overline-line,.katex .underline .underline-line{border-bottom-style:solid;display:inline-block;width:100%}.katex .hdashline{border-bottom-style:dashed;display:inline-block;width:100%}.katex .sqrt>.root{margin-left:.27777778em;margin-right:-.55555556em}.katex .fontsize-ensurer.reset-size1.size1,.katex .sizing.reset-size1.size1{font-size:1em}.katex .fontsize-ensurer.reset-size1.size2,.katex .sizing.reset-size1.size2{font-size:1.2em}.katex .fontsize-ensurer.reset-size1.size3,.katex .sizing.reset-size1.size3{font-size:1.4em}.katex .fontsize-ensurer.reset-size1.size4,.katex .sizing.reset-size1.size4{font-size:1.6em}.katex .fontsize-ensurer.reset-size1.size5,.katex .sizing.reset-size1.size5{font-size:1.8em}.katex .fontsize-ensurer.reset-size1.size6,.katex .sizing.reset-size1.size6{font-size:2em}.katex .fontsize-ensurer.reset-size1.size7,.katex .sizing.reset-size1.size7{font-size:2.4em}.katex .fontsize-ensurer.reset-size1.size8,.katex .sizing.reset-size1.size8{font-size:2.88em}.katex .fontsize-ensurer.reset-size1.size9,.katex .sizing.reset-size1.size9{font-size:3.456em}.katex .fontsize-ensurer.reset-size1.size10,.katex .sizing.reset-size1.size10{font-size:4.148em}.katex .fontsize-ensurer.reset-size1.size11,.katex .sizing.reset-size1.size11{font-size:4.976em}.katex .fontsize-ensurer.reset-size2.size1,.katex .sizing.reset-size2.size1{font-size:.83333333em}.katex .fontsize-ensurer.reset-size2.size2,.katex .sizing.reset-size2.size2{font-size:1em}.katex .fontsize-ensurer.reset-size2.size3,.katex .sizing.reset-size2.size3{font-size:1.16666667em}.katex .fontsize-ensurer.reset-size2.size4,.katex .sizing.reset-size2.size4{font-size:1.33333333em}.katex .fontsize-ensurer.reset-size2.size5,.katex .sizing.reset-size2.size5{font-size:1.5em}.katex .fontsize-ensurer.reset-size2.size6,.katex .sizing.reset-size2.size6{font-size:1.66666667em}.katex .fontsize-ensurer.reset-size2.size7,.katex .sizing.reset-size2.size7{font-size:2em}.katex .fontsize-ensurer.reset-size2.size8,.katex .sizing.reset-size2.size8{font-size:2.4em}.katex .fontsize-ensurer.reset-size2.size9,.katex .sizing.reset-size2.size9{font-size:2.88em}.katex .fontsize-ensurer.reset-size2.size10,.katex .sizing.reset-size2.size10{font-size:3.45666667em}.katex .fontsize-ensurer.reset-size2.size11,.katex .sizing.reset-size2.size11{font-size:4.14666667em}.katex .fontsize-ensurer.reset-size3.size1,.katex .sizing.reset-size3.size1{font-size:.71428571em}.katex .fontsize-ensurer.reset-size3.size2,.katex .sizing.reset-size3.size2{font-size:.85714286em}.katex .fontsize-ensurer.reset-size3.size3,.katex .sizing.reset-size3.size3{font-size:1em}.katex .fontsize-ensurer.reset-size3.size4,.katex .sizing.reset-size3.size4{font-size:1.14285714em}.katex .fontsize-ensurer.reset-size3.size5,.katex .sizing.reset-size3.size5{font-size:1.28571429em}.katex .fontsize-ensurer.reset-size3.size6,.katex .sizing.reset-size3.size6{font-size:1.42857143em}.katex .fontsize-ensurer.reset-size3.size7,.katex .sizing.reset-size3.size7{font-size:1.71428571em}.katex .fontsize-ensurer.reset-size3.size8,.katex .sizing.reset-size3.size8{font-size:2.05714286em}.katex .fontsize-ensurer.reset-size3.size9,.katex .sizing.reset-size3.size9{font-size:2.46857143em}.katex .fontsize-ensurer.reset-size3.size10,.katex .sizing.reset-size3.size10{font-size:2.96285714em}.katex .fontsize-ensurer.reset-size3.size11,.katex .sizing.reset-size3.size11{font-size:3.55428571em}.katex .fontsize-ensurer.reset-size4.size1,.katex .sizing.reset-size4.size1{font-size:.625em}.katex .fontsize-ensurer.reset-size4.size2,.katex .sizing.reset-size4.size2{font-size:.75em}.katex .fontsize-ensurer.reset-size4.size3,.katex .sizing.reset-size4.size3{font-size:.875em}.katex .fontsize-ensurer.reset-size4.size4,.katex .sizing.reset-size4.size4{font-size:1em}.katex .fontsize-ensurer.reset-size4.size5,.katex .sizing.reset-size4.size5{font-size:1.125em}.katex .fontsize-ensurer.reset-size4.size6,.katex .sizing.reset-size4.size6{font-size:1.25em}.katex .fontsize-ensurer.reset-size4.size7,.katex .sizing.reset-size4.size7{font-size:1.5em}.katex .fontsize-ensurer.reset-size4.size8,.katex .sizing.reset-size4.size8{font-size:1.8em}.katex .fontsize-ensurer.reset-size4.size9,.katex .sizing.reset-size4.size9{font-size:2.16em}.katex .fontsize-ensurer.reset-size4.size10,.katex .sizing.reset-size4.size10{font-size:2.5925em}.katex .fontsize-ensurer.reset-size4.size11,.katex .sizing.reset-size4.size11{font-size:3.11em}.katex .fontsize-ensurer.reset-size5.size1,.katex .sizing.reset-size5.size1{font-size:.55555556em}.katex .fontsize-ensurer.reset-size5.size2,.katex .sizing.reset-size5.size2{font-size:.66666667em}.katex .fontsize-ensurer.reset-size5.size3,.katex .sizing.reset-size5.size3{font-size:.77777778em}.katex .fontsize-ensurer.reset-size5.size4,.katex .sizing.reset-size5.size4{font-size:.88888889em}.katex .fontsize-ensurer.reset-size5.size5,.katex .sizing.reset-size5.size5{font-size:1em}.katex .fontsize-ensurer.reset-size5.size6,.katex .sizing.reset-size5.size6{font-size:1.11111111em}.katex .fontsize-ensurer.reset-size5.size7,.katex .sizing.reset-size5.size7{font-size:1.33333333em}.katex .fontsize-ensurer.reset-size5.size8,.katex .sizing.reset-size5.size8{font-size:1.6em}.katex .fontsize-ensurer.reset-size5.size9,.katex .sizing.reset-size5.size9{font-size:1.92em}.katex .fontsize-ensurer.reset-size5.size10,.katex .sizing.reset-size5.size10{font-size:2.30444444em}.katex .fontsize-ensurer.reset-size5.size11,.katex .sizing.reset-size5.size11{font-size:2.76444444em}.katex .fontsize-ensurer.reset-size6.size1,.katex .sizing.reset-size6.size1{font-size:.5em}.katex .fontsize-ensurer.reset-size6.size2,.katex .sizing.reset-size6.size2{font-size:.6em}.katex .fontsize-ensurer.reset-size6.size3,.katex .sizing.reset-size6.size3{font-size:.7em}.katex .fontsize-ensurer.reset-size6.size4,.katex .sizing.reset-size6.size4{font-size:.8em}.katex .fontsize-ensurer.reset-size6.size5,.katex .sizing.reset-size6.size5{font-size:.9em}.katex .fontsize-ensurer.reset-size6.size6,.katex .sizing.reset-size6.size6{font-size:1em}.katex .fontsize-ensurer.reset-size6.size7,.katex .sizing.reset-size6.size7{font-size:1.2em}.katex .fontsize-ensurer.reset-size6.size8,.katex .sizing.reset-size6.size8{font-size:1.44em}.katex .fontsize-ensurer.reset-size6.size9,.katex .sizing.reset-size6.size9{font-size:1.728em}.katex .fontsize-ensurer.reset-size6.size10,.katex .sizing.reset-size6.size10{font-size:2.074em}.katex .fontsize-ensurer.reset-size6.size11,.katex .sizing.reset-size6.size11{font-size:2.488em}.katex .fontsize-ensurer.reset-size7.size1,.katex .sizing.reset-size7.size1{font-size:.41666667em}.katex .fontsize-ensurer.reset-size7.size2,.katex .sizing.reset-size7.size2{font-size:.5em}.katex .fontsize-ensurer.reset-size7.size3,.katex .sizing.reset-size7.size3{font-size:.58333333em}.katex .fontsize-ensurer.reset-size7.size4,.katex .sizing.reset-size7.size4{font-size:.66666667em}.katex .fontsize-ensurer.reset-size7.size5,.katex .sizing.reset-size7.size5{font-size:.75em}.katex .fontsize-ensurer.reset-size7.size6,.katex .sizing.reset-size7.size6{font-size:.83333333em}.katex .fontsize-ensurer.reset-size7.size7,.katex .sizing.reset-size7.size7{font-size:1em}.katex .fontsize-ensurer.reset-size7.size8,.katex .sizing.reset-size7.size8{font-size:1.2em}.katex .fontsize-ensurer.reset-size7.size9,.katex .sizing.reset-size7.size9{font-size:1.44em}.katex .fontsize-ensurer.reset-size7.size10,.katex .sizing.reset-size7.size10{font-size:1.72833333em}.katex .fontsize-ensurer.reset-size7.size11,.katex .sizing.reset-size7.size11{font-size:2.07333333em}.katex .fontsize-ensurer.reset-size8.size1,.katex .sizing.reset-size8.size1{font-size:.34722222em}.katex .fontsize-ensurer.reset-size8.size2,.katex .sizing.reset-size8.size2{font-size:.41666667em}.katex .fontsize-ensurer.reset-size8.size3,.katex .sizing.reset-size8.size3{font-size:.48611111em}.katex .fontsize-ensurer.reset-size8.size4,.katex .sizing.reset-size8.size4{font-size:.55555556em}.katex .fontsize-ensurer.reset-size8.size5,.katex .sizing.reset-size8.size5{font-size:.625em}.katex .fontsize-ensurer.reset-size8.size6,.katex .sizing.reset-size8.size6{font-size:.69444444em}.katex .fontsize-ensurer.reset-size8.size7,.katex .sizing.reset-size8.size7{font-size:.83333333em}.katex .fontsize-ensurer.reset-size8.size8,.katex .sizing.reset-size8.size8{font-size:1em}.katex .fontsize-ensurer.reset-size8.size9,.katex .sizing.reset-size8.size9{font-size:1.2em}.katex .fontsize-ensurer.reset-size8.size10,.katex .sizing.reset-size8.size10{font-size:1.44027778em}.katex .fontsize-ensurer.reset-size8.size11,.katex .sizing.reset-size8.size11{font-size:1.72777778em}.katex .fontsize-ensurer.reset-size9.size1,.katex .sizing.reset-size9.size1{font-size:.28935185em}.katex .fontsize-ensurer.reset-size9.size2,.katex .sizing.reset-size9.size2{font-size:.34722222em}.katex .fontsize-ensurer.reset-size9.size3,.katex .sizing.reset-size9.size3{font-size:.40509259em}.katex .fontsize-ensurer.reset-size9.size4,.katex .sizing.reset-size9.size4{font-size:.46296296em}.katex .fontsize-ensurer.reset-size9.size5,.katex .sizing.reset-size9.size5{font-size:.52083333em}.katex .fontsize-ensurer.reset-size9.size6,.katex .sizing.reset-size9.size6{font-size:.5787037em}.katex .fontsize-ensurer.reset-size9.size7,.katex .sizing.reset-size9.size7{font-size:.69444444em}.katex .fontsize-ensurer.reset-size9.size8,.katex .sizing.reset-size9.size8{font-size:.83333333em}.katex .fontsize-ensurer.reset-size9.size9,.katex .sizing.reset-size9.size9{font-size:1em}.katex .fontsize-ensurer.reset-size9.size10,.katex .sizing.reset-size9.size10{font-size:1.20023148em}.katex .fontsize-ensurer.reset-size9.size11,.katex .sizing.reset-size9.size11{font-size:1.43981481em}.katex .fontsize-ensurer.reset-size10.size1,.katex .sizing.reset-size10.size1{font-size:.24108004em}.katex .fontsize-ensurer.reset-size10.size2,.katex .sizing.reset-size10.size2{font-size:.28929605em}.katex .fontsize-ensurer.reset-size10.size3,.katex .sizing.reset-size10.size3{font-size:.33751205em}.katex .fontsize-ensurer.reset-size10.size4,.katex .sizing.reset-size10.size4{font-size:.38572806em}.katex .fontsize-ensurer.reset-size10.size5,.katex .sizing.reset-size10.size5{font-size:.43394407em}.katex .fontsize-ensurer.reset-size10.size6,.katex .sizing.reset-size10.size6{font-size:.48216008em}.katex .fontsize-ensurer.reset-size10.size7,.katex .sizing.reset-size10.size7{font-size:.57859209em}.katex .fontsize-ensurer.reset-size10.size8,.katex .sizing.reset-size10.size8{font-size:.69431051em}.katex .fontsize-ensurer.reset-size10.size9,.katex .sizing.reset-size10.size9{font-size:.83317261em}.katex .fontsize-ensurer.reset-size10.size10,.katex .sizing.reset-size10.size10{font-size:1em}.katex .fontsize-ensurer.reset-size10.size11,.katex .sizing.reset-size10.size11{font-size:1.19961427em}.katex .fontsize-ensurer.reset-size11.size1,.katex .sizing.reset-size11.size1{font-size:.20096463em}.katex .fontsize-ensurer.reset-size11.size2,.katex .sizing.reset-size11.size2{font-size:.24115756em}.katex .fontsize-ensurer.reset-size11.size3,.katex .sizing.reset-size11.size3{font-size:.28135048em}.katex .fontsize-ensurer.reset-size11.size4,.katex .sizing.reset-size11.size4{font-size:.32154341em}.katex .fontsize-ensurer.reset-size11.size5,.katex .sizing.reset-size11.size5{font-size:.36173633em}.katex .fontsize-ensurer.reset-size11.size6,.katex .sizing.reset-size11.size6{font-size:.40192926em}.katex .fontsize-ensurer.reset-size11.size7,.katex .sizing.reset-size11.size7{font-size:.48231511em}.katex .fontsize-ensurer.reset-size11.size8,.katex .sizing.reset-size11.size8{font-size:.57877814em}.katex .fontsize-ensurer.reset-size11.size9,.katex .sizing.reset-size11.size9{font-size:.69453376em}.katex .fontsize-ensurer.reset-size11.size10,.katex .sizing.reset-size11.size10{font-size:.83360129em}.katex .fontsize-ensurer.reset-size11.size11,.katex .sizing.reset-size11.size11{font-size:1em}.katex .delimsizing.size1{font-family:KaTeX_Size1}.katex .delimsizing.size2{font-family:KaTeX_Size2}.katex .delimsizing.size3{font-family:KaTeX_Size3}.katex .delimsizing.size4{font-family:KaTeX_Size4}.katex .delimsizing.mult .delim-size1>span{font-family:KaTeX_Size1}.katex .delimsizing.mult .delim-size4>span{font-family:KaTeX_Size4}.katex .nulldelimiter{display:inline-block;width:.12em}.katex .delimcenter,.katex .op-symbol{position:relative}.katex .op-symbol.small-op{font-family:KaTeX_Size1}.katex .op-symbol.large-op{font-family:KaTeX_Size2}.katex .accent>.vlist-t,.katex .op-limits>.vlist-t{text-align:center}.katex .accent .accent-body{position:relative}.katex .accent .accent-body:not(.accent-full){width:0}.katex .overlay{display:block}.katex .mtable .vertical-separator{display:inline-block;min-width:1px}.katex .mtable .arraycolsep{display:inline-block}.katex .mtable .col-align-c>.vlist-t{text-align:center}.katex .mtable .col-align-l>.vlist-t{text-align:left}.katex .mtable .col-align-r>.vlist-t{text-align:right}.katex .svg-align{text-align:left}.katex svg{fill:currentColor;stroke:currentColor;fill-rule:nonzero;fill-opacity:1;stroke-width:1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;display:block;height:inherit;position:absolute;width:100%}.katex svg path{stroke:none}.katex img{border-style:none;max-height:none;max-width:none;min-height:0;min-width:0}.katex .stretchy{display:block;overflow:hidden;position:relative;width:100%}.katex .stretchy:after,.katex .stretchy:before{content:""}.katex .hide-tail{overflow:hidden;position:relative;width:100%}.katex .halfarrow-left{left:0;overflow:hidden;position:absolute;width:50.2%}.katex .halfarrow-right{overflow:hidden;position:absolute;right:0;width:50.2%}.katex .brace-left{left:0;overflow:hidden;position:absolute;width:25.1%}.katex .brace-center{left:25%;overflow:hidden;position:absolute;width:50%}.katex .brace-right{overflow:hidden;position:absolute;right:0;width:25.1%}.katex .x-arrow-pad{padding:0 .5em}.katex .cd-arrow-pad{padding:0 .55556em 0 .27778em}.katex .mover,.katex .munder,.katex .x-arrow{text-align:center}.katex .boxpad{padding:0 .3em}.katex .fbox,.katex .fcolorbox{border:.04em solid;box-sizing:border-box}.katex .cancel-pad{padding:0 .2em}.katex .cancel-lap{margin-left:-.2em;margin-right:-.2em}.katex .sout{border-bottom-style:solid;border-bottom-width:.08em}.katex .angl{border-right:.049em solid;border-top:.049em solid;box-sizing:border-box;margin-right:.03889em}.katex .anglpad{padding:0 .03889em}.katex .eqn-num:before{content:"(" counter(katexEqnNo) ")";counter-increment:katexEqnNo}.katex .mml-eqn-num:before{content:"(" counter(mmlEqnNo) ")";counter-increment:mmlEqnNo}.katex .mtr-glue{width:50%}.katex .cd-vert-arrow{display:inline-block;position:relative}.katex .cd-label-left{display:inline-block;position:absolute;right:calc(50% + .3em);text-align:left}.katex .cd-label-right{display:inline-block;left:calc(50% + .3em);position:absolute;text-align:right}.katex-display{display:block;margin:1em 0;text-align:center}.katex-display>.katex{display:block;text-align:center;white-space:nowrap}.katex-display>.katex>.katex-html{display:block;position:relative}.katex-display>.katex>.katex-html>.tag{position:absolute;right:0}.katex-display.leqno>.katex>.katex-html>.tag{left:0;right:auto}.katex-display.fleqn>.katex{padding-left:2em;text-align:left}body{counter-reset:katexEqnNo mmlEqnNo}
</style>
<style>/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

.katex-error {
	color: var(--vscode-editorError-foreground);
}
</style>
<style>html,
body,
.github-markdown-body {
    padding: 0 !important;
    max-width: auto !important;
}

.github-markdown-body {
    background-color: var(--color-canvas-default);
    color: var(--color-fg-default);
}

.github-markdown-body {
    border: 1px solid transparent;
    box-sizing: border-box;
    margin: 0 auto;
    width: 100% !important;
}

.github-markdown-content {
    padding: 32px !important;
    max-width: 980px;
    min-width: 200px;
    margin: 0 auto;
}


.vscode-body.scrollBeyondLastLine {
    margin-bottom: 0;
}
.vscode-body.scrollBeyondLastLine .github-markdown-body {
    padding-bottom: calc(100vh + 10px) !important;
}

.github-markdown-body blockquote {
    background-color: initial;
}

.github-markdown-body pre {
    color: initial;
}

.github-markdown-body code {
    color: inherit;
}

.github-markdown-body pre code {
    color: initial;
}

.github-markdown-body code > div {
    background: none
}

.github-markdown-body.showEditorSelection .code-line .code-line:hover:before {
	border-left: none;
}

.github-markdown-body p,
.github-markdown-body blockquote,
.github-markdown-body ul,
.github-markdown-body ol,
.github-markdown-body dl,
.github-markdown-body table,
.github-markdown-body pre {
  margin-top: 16px;
  margin-bottom: 16px;
}

.vscode-dark.showEditorSelection .code-line:hover:before {
    border-left: 3px solid var(--color-fg-default);
}</style>
<style>.github-markdown-body {
  -ms-text-size-adjust: 100%;
  -webkit-text-size-adjust: 100%;
  margin: 0;
  color: var(--color-fg-default);
  background-color: var(--color-canvas-default);
  font-family: -apple-system,BlinkMacSystemFont,"Segoe UI","Noto Sans",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji";
  font-size: 16px;
  line-height: 1.5;
  word-wrap: break-word;
}

.github-markdown-body .octicon {
  display: inline-block;
  fill: currentColor;
  vertical-align: text-bottom;
}

.github-markdown-body h1:hover .anchor .octicon-link:before,
.github-markdown-body h2:hover .anchor .octicon-link:before,
.github-markdown-body h3:hover .anchor .octicon-link:before,
.github-markdown-body h4:hover .anchor .octicon-link:before,
.github-markdown-body h5:hover .anchor .octicon-link:before,
.github-markdown-body h6:hover .anchor .octicon-link:before {
  width: 16px;
  height: 16px;
  content: ' ';
  display: inline-block;
  background-color: currentColor;
  -webkit-mask-image: url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' version='1.1' aria-hidden='true'><path fill-rule='evenodd' d='M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z'></path></svg>");
  mask-image: url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' version='1.1' aria-hidden='true'><path fill-rule='evenodd' d='M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z'></path></svg>");
}

.github-markdown-body details,
.github-markdown-body figcaption,
.github-markdown-body figure {
  display: block;
}

.github-markdown-body summary {
  display: list-item;
}

.github-markdown-body [hidden] {
  display: none !important;
}

.github-markdown-body a {
  background-color: transparent;
  color: var(--color-accent-fg);
  text-decoration: none;
}

.github-markdown-body abbr[title] {
  border-bottom: none;
  text-decoration: underline dotted;
}

.github-markdown-body b,
.github-markdown-body strong {
  font-weight: var(--base-text-weight-semibold, 600);
}

.github-markdown-body dfn {
  font-style: italic;
}

.github-markdown-body h1 {
  margin: .67em 0;
  font-weight: var(--base-text-weight-semibold, 600);
  padding-bottom: .3em;
  font-size: 2em;
  border-bottom: 1px solid var(--color-border-muted);
}

.github-markdown-body mark {
  background-color: var(--color-attention-subtle);
  color: var(--color-fg-default);
}

.github-markdown-body small {
  font-size: 90%;
}

.github-markdown-body sub,
.github-markdown-body sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

.github-markdown-body sub {
  bottom: -0.25em;
}

.github-markdown-body sup {
  top: -0.5em;
}

.github-markdown-body img {
  border-style: none;
  max-width: 100%;
  box-sizing: content-box;
  background-color: var(--color-canvas-default);
}

.github-markdown-body code,
.github-markdown-body kbd,
.github-markdown-body pre,
.github-markdown-body samp {
  font-family: monospace;
  font-size: 1em;
}

.github-markdown-body figure {
  margin: 1em 40px;
}

.github-markdown-body hr {
  box-sizing: content-box;
  overflow: hidden;
  background: transparent;
  border-bottom: 1px solid var(--color-border-muted);
  height: .25em;
  padding: 0;
  margin: 24px 0;
  background-color: var(--color-border-default);
  border: 0;
}

.github-markdown-body input {
  font: inherit;
  margin: 0;
  overflow: visible;
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}

.github-markdown-body [type=button],
.github-markdown-body [type=reset],
.github-markdown-body [type=submit] {
  -webkit-appearance: button;
}

.github-markdown-body [type=checkbox],
.github-markdown-body [type=radio] {
  box-sizing: border-box;
  padding: 0;
}

.github-markdown-body [type=number]::-webkit-inner-spin-button,
.github-markdown-body [type=number]::-webkit-outer-spin-button {
  height: auto;
}

.github-markdown-body [type=search]::-webkit-search-cancel-button,
.github-markdown-body [type=search]::-webkit-search-decoration {
  -webkit-appearance: none;
}

.github-markdown-body ::-webkit-input-placeholder {
  color: inherit;
  opacity: .54;
}

.github-markdown-body ::-webkit-file-upload-button {
  -webkit-appearance: button;
  font: inherit;
}

.github-markdown-body a:hover {
  text-decoration: underline;
}

.github-markdown-body ::placeholder {
  color: var(--color-fg-subtle);
  opacity: 1;
}

.github-markdown-body hr::before {
  display: table;
  content: "";
}

.github-markdown-body hr::after {
  display: table;
  clear: both;
  content: "";
}

.github-markdown-body table {
  border-spacing: 0;
  border-collapse: collapse;
  display: block;
  width: max-content;
  max-width: 100%;
  overflow: auto;
}

.github-markdown-body td,
.github-markdown-body th {
  padding: 0;
}

.github-markdown-body details summary {
  cursor: pointer;
}

.github-markdown-body details:not([open])>*:not(summary) {
  display: none !important;
}

.github-markdown-body a:focus,
.github-markdown-body [role=button]:focus,
.github-markdown-body input[type=radio]:focus,
.github-markdown-body input[type=checkbox]:focus {
  outline: 2px solid var(--color-accent-fg);
  outline-offset: -2px;
  box-shadow: none;
}

.github-markdown-body a:focus:not(:focus-visible),
.github-markdown-body [role=button]:focus:not(:focus-visible),
.github-markdown-body input[type=radio]:focus:not(:focus-visible),
.github-markdown-body input[type=checkbox]:focus:not(:focus-visible) {
  outline: solid 1px transparent;
}

.github-markdown-body a:focus-visible,
.github-markdown-body [role=button]:focus-visible,
.github-markdown-body input[type=radio]:focus-visible,
.github-markdown-body input[type=checkbox]:focus-visible {
  outline: 2px solid var(--color-accent-fg);
  outline-offset: -2px;
  box-shadow: none;
}

.github-markdown-body a:not([class]):focus,
.github-markdown-body a:not([class]):focus-visible,
.github-markdown-body input[type=radio]:focus,
.github-markdown-body input[type=radio]:focus-visible,
.github-markdown-body input[type=checkbox]:focus,
.github-markdown-body input[type=checkbox]:focus-visible {
  outline-offset: 0;
}

.github-markdown-body kbd {
  display: inline-block;
  padding: 3px 5px;
  font: 11px ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace;
  line-height: 10px;
  color: var(--color-fg-default);
  vertical-align: middle;
  background-color: var(--color-canvas-subtle);
  border: solid 1px var(--color-neutral-muted);
  border-bottom-color: var(--color-neutral-muted);
  border-radius: 6px;
  box-shadow: inset 0 -1px 0 var(--color-neutral-muted);
}

.github-markdown-body h1,
.github-markdown-body h2,
.github-markdown-body h3,
.github-markdown-body h4,
.github-markdown-body h5,
.github-markdown-body h6 {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: var(--base-text-weight-semibold, 600);
  line-height: 1.25;
}

.github-markdown-body h2 {
  font-weight: var(--base-text-weight-semibold, 600);
  padding-bottom: .3em;
  font-size: 1.5em;
  border-bottom: 1px solid var(--color-border-muted);
}

.github-markdown-body h3 {
  font-weight: var(--base-text-weight-semibold, 600);
  font-size: 1.25em;
}

.github-markdown-body h4 {
  font-weight: var(--base-text-weight-semibold, 600);
  font-size: 1em;
}

.github-markdown-body h5 {
  font-weight: var(--base-text-weight-semibold, 600);
  font-size: .875em;
}

.github-markdown-body h6 {
  font-weight: var(--base-text-weight-semibold, 600);
  font-size: .85em;
  color: var(--color-fg-muted);
}

.github-markdown-body p {
  margin-top: 0;
  margin-bottom: 10px;
}

.github-markdown-body blockquote {
  margin: 0;
  padding: 0 1em;
  color: var(--color-fg-muted);
  border-left: .25em solid var(--color-border-default);
}

.github-markdown-body ul,
.github-markdown-body ol {
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 2em;
}

.github-markdown-body ol ol,
.github-markdown-body ul ol {
  list-style-type: lower-roman;
}

.github-markdown-body ul ul ol,
.github-markdown-body ul ol ol,
.github-markdown-body ol ul ol,
.github-markdown-body ol ol ol {
  list-style-type: lower-alpha;
}

.github-markdown-body dd {
  margin-left: 0;
}

.github-markdown-body tt,
.github-markdown-body code,
.github-markdown-body samp {
  font-family: ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace;
  font-size: 12px;
}

.github-markdown-body pre {
  margin-top: 0;
  margin-bottom: 0;
  font-family: ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace;
  font-size: 12px;
  word-wrap: normal;
}

.github-markdown-body .octicon {
  display: inline-block;
  overflow: visible !important;
  vertical-align: text-bottom;
  fill: currentColor;
}

.github-markdown-body input::-webkit-outer-spin-button,
.github-markdown-body input::-webkit-inner-spin-button {
  margin: 0;
  -webkit-appearance: none;
  appearance: none;
}

.github-markdown-body::before {
  display: table;
  content: "";
}

.github-markdown-body::after {
  display: table;
  clear: both;
  content: "";
}

.github-markdown-body>*:first-child {
  margin-top: 0 !important;
}

.github-markdown-body>*:last-child {
  margin-bottom: 0 !important;
}

.github-markdown-body a:not([href]) {
  color: inherit;
  text-decoration: none;
}

.github-markdown-body .absent {
  color: var(--color-danger-fg);
}

.github-markdown-body .anchor {
  float: left;
  padding-right: 4px;
  margin-left: -20px;
  line-height: 1;
}

.github-markdown-body .anchor:focus {
  outline: none;
}

.github-markdown-body p,
.github-markdown-body blockquote,
.github-markdown-body ul,
.github-markdown-body ol,
.github-markdown-body dl,
.github-markdown-body table,
.github-markdown-body pre,
.github-markdown-body details {
  margin-top: 0;
  margin-bottom: 16px;
}

.github-markdown-body blockquote>:first-child {
  margin-top: 0;
}

.github-markdown-body blockquote>:last-child {
  margin-bottom: 0;
}

.github-markdown-body h1 .octicon-link,
.github-markdown-body h2 .octicon-link,
.github-markdown-body h3 .octicon-link,
.github-markdown-body h4 .octicon-link,
.github-markdown-body h5 .octicon-link,
.github-markdown-body h6 .octicon-link {
  color: var(--color-fg-default);
  vertical-align: middle;
  visibility: hidden;
}

.github-markdown-body h1:hover .anchor,
.github-markdown-body h2:hover .anchor,
.github-markdown-body h3:hover .anchor,
.github-markdown-body h4:hover .anchor,
.github-markdown-body h5:hover .anchor,
.github-markdown-body h6:hover .anchor {
  text-decoration: none;
}

.github-markdown-body h1:hover .anchor .octicon-link,
.github-markdown-body h2:hover .anchor .octicon-link,
.github-markdown-body h3:hover .anchor .octicon-link,
.github-markdown-body h4:hover .anchor .octicon-link,
.github-markdown-body h5:hover .anchor .octicon-link,
.github-markdown-body h6:hover .anchor .octicon-link {
  visibility: visible;
}

.github-markdown-body h1 tt,
.github-markdown-body h1 code,
.github-markdown-body h2 tt,
.github-markdown-body h2 code,
.github-markdown-body h3 tt,
.github-markdown-body h3 code,
.github-markdown-body h4 tt,
.github-markdown-body h4 code,
.github-markdown-body h5 tt,
.github-markdown-body h5 code,
.github-markdown-body h6 tt,
.github-markdown-body h6 code {
  padding: 0 .2em;
  font-size: inherit;
}

.github-markdown-body summary h1,
.github-markdown-body summary h2,
.github-markdown-body summary h3,
.github-markdown-body summary h4,
.github-markdown-body summary h5,
.github-markdown-body summary h6 {
  display: inline-block;
}

.github-markdown-body summary h1 .anchor,
.github-markdown-body summary h2 .anchor,
.github-markdown-body summary h3 .anchor,
.github-markdown-body summary h4 .anchor,
.github-markdown-body summary h5 .anchor,
.github-markdown-body summary h6 .anchor {
  margin-left: -40px;
}

.github-markdown-body summary h1,
.github-markdown-body summary h2 {
  padding-bottom: 0;
  border-bottom: 0;
}

.github-markdown-body ul.no-list,
.github-markdown-body ol.no-list {
  padding: 0;
  list-style-type: none;
}

.github-markdown-body ol[type=a] {
  list-style-type: lower-alpha;
}

.github-markdown-body ol[type=A] {
  list-style-type: upper-alpha;
}

.github-markdown-body ol[type=i] {
  list-style-type: lower-roman;
}

.github-markdown-body ol[type=I] {
  list-style-type: upper-roman;
}

.github-markdown-body ol[type="1"] {
  list-style-type: decimal;
}

.github-markdown-body div>ol:not([type]) {
  list-style-type: decimal;
}

.github-markdown-body ul ul,
.github-markdown-body ul ol,
.github-markdown-body ol ol,
.github-markdown-body ol ul {
  margin-top: 0;
  margin-bottom: 0;
}

.github-markdown-body li>p {
  margin-top: 16px;
}

.github-markdown-body li+li {
  margin-top: .25em;
}

.github-markdown-body dl {
  padding: 0;
}

.github-markdown-body dl dt {
  padding: 0;
  margin-top: 16px;
  font-size: 1em;
  font-style: italic;
  font-weight: var(--base-text-weight-semibold, 600);
}

.github-markdown-body dl dd {
  padding: 0 16px;
  margin-bottom: 16px;
}

.github-markdown-body table th {
  font-weight: var(--base-text-weight-semibold, 600);
}

.github-markdown-body table th,
.github-markdown-body table td {
  padding: 6px 13px;
  border: 1px solid var(--color-border-default);
}

.github-markdown-body table td>:last-child {
  margin-bottom: 0;
}

.github-markdown-body table tr {
  background-color: var(--color-canvas-default);
  border-top: 1px solid var(--color-border-muted);
}

.github-markdown-body table tr:nth-child(2n) {
  background-color: var(--color-canvas-subtle);
}

.github-markdown-body table img {
  background-color: transparent;
}

.github-markdown-body img[align=right] {
  padding-left: 20px;
}

.github-markdown-body img[align=left] {
  padding-right: 20px;
}

.github-markdown-body .emoji {
  max-width: none;
  vertical-align: text-top;
  background-color: transparent;
}

.github-markdown-body span.frame {
  display: block;
  overflow: hidden;
}

.github-markdown-body span.frame>span {
  display: block;
  float: left;
  width: auto;
  padding: 7px;
  margin: 13px 0 0;
  overflow: hidden;
  border: 1px solid var(--color-border-default);
}

.github-markdown-body span.frame span img {
  display: block;
  float: left;
}

.github-markdown-body span.frame span span {
  display: block;
  padding: 5px 0 0;
  clear: both;
  color: var(--color-fg-default);
}

.github-markdown-body span.align-center {
  display: block;
  overflow: hidden;
  clear: both;
}

.github-markdown-body span.align-center>span {
  display: block;
  margin: 13px auto 0;
  overflow: hidden;
  text-align: center;
}

.github-markdown-body span.align-center span img {
  margin: 0 auto;
  text-align: center;
}

.github-markdown-body span.align-right {
  display: block;
  overflow: hidden;
  clear: both;
}

.github-markdown-body span.align-right>span {
  display: block;
  margin: 13px 0 0;
  overflow: hidden;
  text-align: right;
}

.github-markdown-body span.align-right span img {
  margin: 0;
  text-align: right;
}

.github-markdown-body span.float-left {
  display: block;
  float: left;
  margin-right: 13px;
  overflow: hidden;
}

.github-markdown-body span.float-left span {
  margin: 13px 0 0;
}

.github-markdown-body span.float-right {
  display: block;
  float: right;
  margin-left: 13px;
  overflow: hidden;
}

.github-markdown-body span.float-right>span {
  display: block;
  margin: 13px auto 0;
  overflow: hidden;
  text-align: right;
}

.github-markdown-body code,
.github-markdown-body tt {
  padding: .2em .4em;
  margin: 0;
  font-size: 85%;
  white-space: break-spaces;
  background-color: var(--color-neutral-muted);
  border-radius: 6px;
}

.github-markdown-body code br,
.github-markdown-body tt br {
  display: none;
}

.github-markdown-body del code {
  text-decoration: inherit;
}

.github-markdown-body samp {
  font-size: 85%;
}

.github-markdown-body pre code {
  font-size: 100%;
}

.github-markdown-body pre>code {
  padding: 0;
  margin: 0;
  word-break: normal;
  white-space: pre;
  background: transparent;
  border: 0;
}

.github-markdown-body .highlight {
  margin-bottom: 16px;
}

.github-markdown-body .highlight pre {
  margin-bottom: 0;
  word-break: normal;
}

.github-markdown-body .highlight pre,
.github-markdown-body pre {
  padding: 16px;
  overflow: auto;
  font-size: 85%;
  line-height: 1.45;
  color: var(--color-fg-default);
  background-color: var(--color-canvas-subtle);
  border-radius: 6px;
}

.github-markdown-body pre code,
.github-markdown-body pre tt {
  display: inline;
  max-width: auto;
  padding: 0;
  margin: 0;
  overflow: visible;
  line-height: inherit;
  word-wrap: normal;
  background-color: transparent;
  border: 0;
}

.github-markdown-body .csv-data td,
.github-markdown-body .csv-data th {
  padding: 5px;
  overflow: hidden;
  font-size: 12px;
  line-height: 1;
  text-align: left;
  white-space: nowrap;
}

.github-markdown-body .csv-data .blob-num {
  padding: 10px 8px 9px;
  text-align: right;
  background: var(--color-canvas-default);
  border: 0;
}

.github-markdown-body .csv-data tr {
  border-top: 0;
}

.github-markdown-body .csv-data th {
  font-weight: var(--base-text-weight-semibold, 600);
  background: var(--color-canvas-subtle);
  border-top: 0;
}

.github-markdown-body [data-footnote-ref]::before {
  content: "[";
}

.github-markdown-body [data-footnote-ref]::after {
  content: "]";
}

.github-markdown-body .footnotes {
  font-size: 12px;
  color: var(--color-fg-muted);
  border-top: 1px solid var(--color-border-default);
}

.github-markdown-body .footnotes ol {
  padding-left: 16px;
}

.github-markdown-body .footnotes ol ul {
  display: inline-block;
  padding-left: 16px;
  margin-top: 16px;
}

.github-markdown-body .footnotes li {
  position: relative;
}

.github-markdown-body .footnotes li:target::before {
  position: absolute;
  top: -8px;
  right: -8px;
  bottom: -8px;
  left: -24px;
  pointer-events: none;
  content: "";
  border: 2px solid var(--color-accent-emphasis);
  border-radius: 6px;
}

.github-markdown-body .footnotes li:target {
  color: var(--color-fg-default);
}

.github-markdown-body .footnotes .data-footnote-backref g-emoji {
  font-family: monospace;
}

.github-markdown-body [popover] {
  background: canvas;
  border: solid;
  color: canvastext;
  height: fit-content;
  inset: 0;
  margin: auto;
  overflow: auto;
  padding: .25em;
  position: fixed;
  width: fit-content;
  z-index: 2147483647;
}

.github-markdown-body [popover][anchor] {
  inset: auto;
}

.github-markdown-body .pl-c {
  color: var(--color-prettylights-syntax-comment);
}

.github-markdown-body .pl-c1,
.github-markdown-body .pl-s .pl-v {
  color: var(--color-prettylights-syntax-constant);
}

.github-markdown-body .pl-e,
.github-markdown-body .pl-en {
  color: var(--color-prettylights-syntax-entity);
}

.github-markdown-body .pl-smi,
.github-markdown-body .pl-s .pl-s1 {
  color: var(--color-prettylights-syntax-storage-modifier-import);
}

.github-markdown-body .pl-ent {
  color: var(--color-prettylights-syntax-entity-tag);
}

.github-markdown-body .pl-k {
  color: var(--color-prettylights-syntax-keyword);
}

.github-markdown-body .pl-s,
.github-markdown-body .pl-pds,
.github-markdown-body .pl-s .pl-pse .pl-s1,
.github-markdown-body .pl-sr,
.github-markdown-body .pl-sr .pl-cce,
.github-markdown-body .pl-sr .pl-sre,
.github-markdown-body .pl-sr .pl-sra {
  color: var(--color-prettylights-syntax-string);
}

.github-markdown-body .pl-v,
.github-markdown-body .pl-smw {
  color: var(--color-prettylights-syntax-variable);
}

.github-markdown-body .pl-bu {
  color: var(--color-prettylights-syntax-brackethighlighter-unmatched);
}

.github-markdown-body .pl-ii {
  color: var(--color-prettylights-syntax-invalid-illegal-text);
  background-color: var(--color-prettylights-syntax-invalid-illegal-bg);
}

.github-markdown-body .pl-c2 {
  color: var(--color-prettylights-syntax-carriage-return-text);
  background-color: var(--color-prettylights-syntax-carriage-return-bg);
}

.github-markdown-body .pl-sr .pl-cce {
  font-weight: bold;
  color: var(--color-prettylights-syntax-string-regexp);
}

.github-markdown-body .pl-ml {
  color: var(--color-prettylights-syntax-markup-list);
}

.github-markdown-body .pl-mh,
.github-markdown-body .pl-mh .pl-en,
.github-markdown-body .pl-ms {
  font-weight: bold;
  color: var(--color-prettylights-syntax-markup-heading);
}

.github-markdown-body .pl-mi {
  font-style: italic;
  color: var(--color-prettylights-syntax-markup-italic);
}

.github-markdown-body .pl-mb {
  font-weight: bold;
  color: var(--color-prettylights-syntax-markup-bold);
}

.github-markdown-body .pl-md {
  color: var(--color-prettylights-syntax-markup-deleted-text);
  background-color: var(--color-prettylights-syntax-markup-deleted-bg);
}

.github-markdown-body .pl-mi1 {
  color: var(--color-prettylights-syntax-markup-inserted-text);
  background-color: var(--color-prettylights-syntax-markup-inserted-bg);
}

.github-markdown-body .pl-mc {
  color: var(--color-prettylights-syntax-markup-changed-text);
  background-color: var(--color-prettylights-syntax-markup-changed-bg);
}

.github-markdown-body .pl-mi2 {
  color: var(--color-prettylights-syntax-markup-ignored-text);
  background-color: var(--color-prettylights-syntax-markup-ignored-bg);
}

.github-markdown-body .pl-mdr {
  font-weight: bold;
  color: var(--color-prettylights-syntax-meta-diff-range);
}

.github-markdown-body .pl-ba {
  color: var(--color-prettylights-syntax-brackethighlighter-angle);
}

.github-markdown-body .pl-sg {
  color: var(--color-prettylights-syntax-sublimelinter-gutter-mark);
}

.github-markdown-body .pl-corl {
  text-decoration: underline;
  color: var(--color-prettylights-syntax-constant-other-reference-link);
}

.github-markdown-body g-emoji {
  display: inline-block;
  min-width: 1ch;
  font-family: "Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
  font-size: 1em;
  font-style: normal !important;
  font-weight: var(--base-text-weight-normal, 400);
  line-height: 1;
  vertical-align: -0.075em;
}

.github-markdown-body g-emoji img {
  width: 1em;
  height: 1em;
}

.github-markdown-body .task-list-item {
  list-style-type: none;
}

.github-markdown-body .task-list-item label {
  font-weight: var(--base-text-weight-normal, 400);
}

.github-markdown-body .task-list-item.enabled label {
  cursor: pointer;
}

.github-markdown-body .task-list-item+.task-list-item {
  margin-top: 4px;
}

.github-markdown-body .task-list-item .handle {
  display: none;
}

.github-markdown-body .task-list-item-checkbox {
  margin: 0 .2em .25em -1.4em;
  vertical-align: middle;
}

.github-markdown-body .contains-task-list:dir(rtl) .task-list-item-checkbox {
  margin: 0 -1.6em .25em .2em;
}

.github-markdown-body .contains-task-list {
  position: relative;
}

.github-markdown-body .contains-task-list:hover .task-list-item-convert-container,
.github-markdown-body .contains-task-list:focus-within .task-list-item-convert-container {
  display: block;
  width: auto;
  height: 24px;
  overflow: visible;
  clip: auto;
}

.github-markdown-body .QueryBuilder .qb-entity {
  color: var(--color-prettylights-syntax-entity);
}

.github-markdown-body .QueryBuilder .qb-constant {
  color: var(--color-prettylights-syntax-constant);
}

.github-markdown-body ::-webkit-calendar-picker-indicator {
  filter: invert(50%);
}</style>
<style>[data-color-mode=light][data-light-theme=light],
[data-color-mode=dark][data-dark-theme=light],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=light],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=light] {
  /*light*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #116329;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #953800;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #116329;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #116329;
  --color-prettylights-syntax-markup-inserted-bg: #dafbe1;
  --color-prettylights-syntax-markup-changed-text: #953800;
  --color-prettylights-syntax-markup-changed-bg: #ffd8b5;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #1F2328;
  --color-fg-muted: #656d76;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #d1242f;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=light] {
  /*light*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #116329;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #953800;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #116329;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #116329;
  --color-prettylights-syntax-markup-inserted-bg: #dafbe1;
  --color-prettylights-syntax-markup-changed-text: #953800;
  --color-prettylights-syntax-markup-changed-bg: #ffd8b5;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #1F2328;
  --color-fg-muted: #656d76;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #d1242f;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=light] {
  /*light*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #116329;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #953800;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #116329;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #116329;
  --color-prettylights-syntax-markup-inserted-bg: #dafbe1;
  --color-prettylights-syntax-markup-changed-text: #953800;
  --color-prettylights-syntax-markup-changed-bg: #ffd8b5;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #1F2328;
  --color-fg-muted: #656d76;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #d1242f;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=light_colorblind],
[data-color-mode=dark][data-dark-theme=light_colorblind],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=light_colorblind],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=light_colorblind] {
  /*light_colorblind*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #b35900;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #8a4600;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6f3800;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #6f3800;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #b35900;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #6f3800;
  --color-prettylights-syntax-markup-deleted-bg: #fff5e8;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #8a4600;
  --color-prettylights-syntax-markup-changed-bg: #ffddb0;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #b35900;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=light_colorblind] {
  /*light_colorblind*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #b35900;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #8a4600;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6f3800;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #6f3800;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #b35900;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #6f3800;
  --color-prettylights-syntax-markup-deleted-bg: #fff5e8;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #8a4600;
  --color-prettylights-syntax-markup-changed-bg: #ffddb0;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #b35900;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=light_colorblind] {
  /*light_colorblind*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #b35900;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #8a4600;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6f3800;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #6f3800;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #b35900;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #6f3800;
  --color-prettylights-syntax-markup-deleted-bg: #fff5e8;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #8a4600;
  --color-prettylights-syntax-markup-changed-bg: #ffddb0;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #b35900;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=light_tritanopia],
[data-color-mode=dark][data-dark-theme=light_tritanopia],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=light_tritanopia],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=light_tritanopia] {
  /*light_tritanopia*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #a40e26;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #a40e26;
  --color-prettylights-syntax-markup-changed-bg: #ffcecb;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #cf222e;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=light_tritanopia] {
  /*light_tritanopia*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #a40e26;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #a40e26;
  --color-prettylights-syntax-markup-changed-bg: #ffcecb;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #cf222e;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=light_tritanopia] {
  /*light_tritanopia*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #6e7781;
  --color-prettylights-syntax-constant: #0550ae;
  --color-prettylights-syntax-entity: #8250df;
  --color-prettylights-syntax-storage-modifier-import: #24292f;
  --color-prettylights-syntax-entity-tag: #0550ae;
  --color-prettylights-syntax-keyword: #cf222e;
  --color-prettylights-syntax-string: #0a3069;
  --color-prettylights-syntax-variable: #a40e26;
  --color-prettylights-syntax-brackethighlighter-unmatched: #82071e;
  --color-prettylights-syntax-invalid-illegal-text: #f6f8fa;
  --color-prettylights-syntax-invalid-illegal-bg: #82071e;
  --color-prettylights-syntax-carriage-return-text: #f6f8fa;
  --color-prettylights-syntax-carriage-return-bg: #cf222e;
  --color-prettylights-syntax-string-regexp: #0550ae;
  --color-prettylights-syntax-markup-list: #3b2300;
  --color-prettylights-syntax-markup-heading: #0550ae;
  --color-prettylights-syntax-markup-italic: #24292f;
  --color-prettylights-syntax-markup-bold: #24292f;
  --color-prettylights-syntax-markup-deleted-text: #82071e;
  --color-prettylights-syntax-markup-deleted-bg: #ffebe9;
  --color-prettylights-syntax-markup-inserted-text: #0550ae;
  --color-prettylights-syntax-markup-inserted-bg: #ddf4ff;
  --color-prettylights-syntax-markup-changed-text: #a40e26;
  --color-prettylights-syntax-markup-changed-bg: #ffcecb;
  --color-prettylights-syntax-markup-ignored-text: #eaeef2;
  --color-prettylights-syntax-markup-ignored-bg: #0550ae;
  --color-prettylights-syntax-meta-diff-range: #8250df;
  --color-prettylights-syntax-brackethighlighter-angle: #57606a;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #8c959f;
  --color-prettylights-syntax-constant-other-reference-link: #0a3069;
  --color-fg-default: #24292f;
  --color-fg-muted: #57606a;
  --color-fg-subtle: #6e7781;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #f6f8fa;
  --color-border-default: #d0d7de;
  --color-border-muted: hsla(210,18%,87%,1);
  --color-neutral-muted: rgba(175,184,193,0.2);
  --color-accent-fg: #0969da;
  --color-accent-emphasis: #0969da;
  --color-attention-subtle: #fff8c5;
  --color-danger-fg: #cf222e;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=light_high_contrast],
[data-color-mode=dark][data-dark-theme=light_high_contrast],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=light_high_contrast],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=light_high_contrast] {
  /*light_high_contrast*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #66707b;
  --color-prettylights-syntax-constant: #023b95;
  --color-prettylights-syntax-entity: #622cbc;
  --color-prettylights-syntax-storage-modifier-import: #0e1116;
  --color-prettylights-syntax-entity-tag: #024c1a;
  --color-prettylights-syntax-keyword: #a0111f;
  --color-prettylights-syntax-string: #032563;
  --color-prettylights-syntax-variable: #702c00;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6e011a;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #6e011a;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #a0111f;
  --color-prettylights-syntax-string-regexp: #024c1a;
  --color-prettylights-syntax-markup-list: #2e1800;
  --color-prettylights-syntax-markup-heading: #023b95;
  --color-prettylights-syntax-markup-italic: #0e1116;
  --color-prettylights-syntax-markup-bold: #0e1116;
  --color-prettylights-syntax-markup-deleted-text: #6e011a;
  --color-prettylights-syntax-markup-deleted-bg: #fff0ee;
  --color-prettylights-syntax-markup-inserted-text: #024c1a;
  --color-prettylights-syntax-markup-inserted-bg: #d2fedb;
  --color-prettylights-syntax-markup-changed-text: #702c00;
  --color-prettylights-syntax-markup-changed-bg: #ffc67b;
  --color-prettylights-syntax-markup-ignored-text: #e7ecf0;
  --color-prettylights-syntax-markup-ignored-bg: #023b95;
  --color-prettylights-syntax-meta-diff-range: #622cbc;
  --color-prettylights-syntax-brackethighlighter-angle: #4b535d;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #88929d;
  --color-prettylights-syntax-constant-other-reference-link: #032563;
  --color-fg-default: #0e1116;
  --color-fg-muted: #0e1116;
  --color-fg-subtle: #66707b;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #e7ecf0;
  --color-border-default: #20252c;
  --color-border-muted: #88929d;
  --color-neutral-muted: rgba(172,182,192,0.2);
  --color-accent-fg: #0349b4;
  --color-accent-emphasis: #0349b4;
  --color-attention-subtle: #fcf7be;
  --color-danger-fg: #d1242f;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=light_high_contrast] {
  /*light_high_contrast*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #66707b;
  --color-prettylights-syntax-constant: #023b95;
  --color-prettylights-syntax-entity: #622cbc;
  --color-prettylights-syntax-storage-modifier-import: #0e1116;
  --color-prettylights-syntax-entity-tag: #024c1a;
  --color-prettylights-syntax-keyword: #a0111f;
  --color-prettylights-syntax-string: #032563;
  --color-prettylights-syntax-variable: #702c00;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6e011a;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #6e011a;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #a0111f;
  --color-prettylights-syntax-string-regexp: #024c1a;
  --color-prettylights-syntax-markup-list: #2e1800;
  --color-prettylights-syntax-markup-heading: #023b95;
  --color-prettylights-syntax-markup-italic: #0e1116;
  --color-prettylights-syntax-markup-bold: #0e1116;
  --color-prettylights-syntax-markup-deleted-text: #6e011a;
  --color-prettylights-syntax-markup-deleted-bg: #fff0ee;
  --color-prettylights-syntax-markup-inserted-text: #024c1a;
  --color-prettylights-syntax-markup-inserted-bg: #d2fedb;
  --color-prettylights-syntax-markup-changed-text: #702c00;
  --color-prettylights-syntax-markup-changed-bg: #ffc67b;
  --color-prettylights-syntax-markup-ignored-text: #e7ecf0;
  --color-prettylights-syntax-markup-ignored-bg: #023b95;
  --color-prettylights-syntax-meta-diff-range: #622cbc;
  --color-prettylights-syntax-brackethighlighter-angle: #4b535d;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #88929d;
  --color-prettylights-syntax-constant-other-reference-link: #032563;
  --color-fg-default: #0e1116;
  --color-fg-muted: #0e1116;
  --color-fg-subtle: #66707b;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #e7ecf0;
  --color-border-default: #20252c;
  --color-border-muted: #88929d;
  --color-neutral-muted: rgba(172,182,192,0.2);
  --color-accent-fg: #0349b4;
  --color-accent-emphasis: #0349b4;
  --color-attention-subtle: #fcf7be;
  --color-danger-fg: #d1242f;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=light_high_contrast] {
  /*light_high_contrast*/
  color-scheme: light;
  --color-prettylights-syntax-comment: #66707b;
  --color-prettylights-syntax-constant: #023b95;
  --color-prettylights-syntax-entity: #622cbc;
  --color-prettylights-syntax-storage-modifier-import: #0e1116;
  --color-prettylights-syntax-entity-tag: #024c1a;
  --color-prettylights-syntax-keyword: #a0111f;
  --color-prettylights-syntax-string: #032563;
  --color-prettylights-syntax-variable: #702c00;
  --color-prettylights-syntax-brackethighlighter-unmatched: #6e011a;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #6e011a;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #a0111f;
  --color-prettylights-syntax-string-regexp: #024c1a;
  --color-prettylights-syntax-markup-list: #2e1800;
  --color-prettylights-syntax-markup-heading: #023b95;
  --color-prettylights-syntax-markup-italic: #0e1116;
  --color-prettylights-syntax-markup-bold: #0e1116;
  --color-prettylights-syntax-markup-deleted-text: #6e011a;
  --color-prettylights-syntax-markup-deleted-bg: #fff0ee;
  --color-prettylights-syntax-markup-inserted-text: #024c1a;
  --color-prettylights-syntax-markup-inserted-bg: #d2fedb;
  --color-prettylights-syntax-markup-changed-text: #702c00;
  --color-prettylights-syntax-markup-changed-bg: #ffc67b;
  --color-prettylights-syntax-markup-ignored-text: #e7ecf0;
  --color-prettylights-syntax-markup-ignored-bg: #023b95;
  --color-prettylights-syntax-meta-diff-range: #622cbc;
  --color-prettylights-syntax-brackethighlighter-angle: #4b535d;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #88929d;
  --color-prettylights-syntax-constant-other-reference-link: #032563;
  --color-fg-default: #0e1116;
  --color-fg-muted: #0e1116;
  --color-fg-subtle: #66707b;
  --color-canvas-default: #ffffff;
  --color-canvas-subtle: #e7ecf0;
  --color-border-default: #20252c;
  --color-border-muted: #88929d;
  --color-neutral-muted: rgba(172,182,192,0.2);
  --color-accent-fg: #0349b4;
  --color-accent-emphasis: #0349b4;
  --color-attention-subtle: #fcf7be;
  --color-danger-fg: #d1242f;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=dark],
[data-color-mode=dark][data-dark-theme=dark],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=dark],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=dark] {
  /*dark*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #7ee787;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa657;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #7ee787;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #aff5b4;
  --color-prettylights-syntax-markup-inserted-bg: #033a16;
  --color-prettylights-syntax-markup-changed-text: #ffdfb6;
  --color-prettylights-syntax-markup-changed-bg: #5a1e02;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #e6edf3;
  --color-fg-muted: #7d8590;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #2f81f7;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=dark] {
  /*dark*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #7ee787;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa657;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #7ee787;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #aff5b4;
  --color-prettylights-syntax-markup-inserted-bg: #033a16;
  --color-prettylights-syntax-markup-changed-text: #ffdfb6;
  --color-prettylights-syntax-markup-changed-bg: #5a1e02;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #e6edf3;
  --color-fg-muted: #7d8590;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #2f81f7;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=dark] {
  /*dark*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #7ee787;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa657;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #7ee787;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #aff5b4;
  --color-prettylights-syntax-markup-inserted-bg: #033a16;
  --color-prettylights-syntax-markup-changed-text: #ffdfb6;
  --color-prettylights-syntax-markup-changed-bg: #5a1e02;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #e6edf3;
  --color-fg-muted: #7d8590;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #2f81f7;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=dark_dimmed],
[data-color-mode=dark][data-dark-theme=dark_dimmed],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=dark_dimmed],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=dark_dimmed] {
  /*dark_dimmed*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #768390;
  --color-prettylights-syntax-constant: #6cb6ff;
  --color-prettylights-syntax-entity: #dcbdfb;
  --color-prettylights-syntax-storage-modifier-import: #adbac7;
  --color-prettylights-syntax-entity-tag: #8ddb8c;
  --color-prettylights-syntax-keyword: #f47067;
  --color-prettylights-syntax-string: #96d0ff;
  --color-prettylights-syntax-variable: #f69d50;
  --color-prettylights-syntax-brackethighlighter-unmatched: #e5534b;
  --color-prettylights-syntax-invalid-illegal-text: #cdd9e5;
  --color-prettylights-syntax-invalid-illegal-bg: #922323;
  --color-prettylights-syntax-carriage-return-text: #cdd9e5;
  --color-prettylights-syntax-carriage-return-bg: #ad2e2c;
  --color-prettylights-syntax-string-regexp: #8ddb8c;
  --color-prettylights-syntax-markup-list: #eac55f;
  --color-prettylights-syntax-markup-heading: #316dca;
  --color-prettylights-syntax-markup-italic: #adbac7;
  --color-prettylights-syntax-markup-bold: #adbac7;
  --color-prettylights-syntax-markup-deleted-text: #ffd8d3;
  --color-prettylights-syntax-markup-deleted-bg: #78191b;
  --color-prettylights-syntax-markup-inserted-text: #b4f1b4;
  --color-prettylights-syntax-markup-inserted-bg: #1b4721;
  --color-prettylights-syntax-markup-changed-text: #ffddb0;
  --color-prettylights-syntax-markup-changed-bg: #682d0f;
  --color-prettylights-syntax-markup-ignored-text: #adbac7;
  --color-prettylights-syntax-markup-ignored-bg: #255ab2;
  --color-prettylights-syntax-meta-diff-range: #dcbdfb;
  --color-prettylights-syntax-brackethighlighter-angle: #768390;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #545d68;
  --color-prettylights-syntax-constant-other-reference-link: #96d0ff;
  --color-fg-default: #adbac7;
  --color-fg-muted: #768390;
  --color-fg-subtle: #636e7b;
  --color-canvas-default: #22272e;
  --color-canvas-subtle: #2d333b;
  --color-border-default: #444c56;
  --color-border-muted: #373e47;
  --color-neutral-muted: rgba(99,110,123,0.4);
  --color-accent-fg: #539bf5;
  --color-accent-emphasis: #316dca;
  --color-attention-subtle: rgba(174,124,20,0.15);
  --color-danger-fg: #e5534b;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=dark_dimmed] {
  /*dark_dimmed*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #768390;
  --color-prettylights-syntax-constant: #6cb6ff;
  --color-prettylights-syntax-entity: #dcbdfb;
  --color-prettylights-syntax-storage-modifier-import: #adbac7;
  --color-prettylights-syntax-entity-tag: #8ddb8c;
  --color-prettylights-syntax-keyword: #f47067;
  --color-prettylights-syntax-string: #96d0ff;
  --color-prettylights-syntax-variable: #f69d50;
  --color-prettylights-syntax-brackethighlighter-unmatched: #e5534b;
  --color-prettylights-syntax-invalid-illegal-text: #cdd9e5;
  --color-prettylights-syntax-invalid-illegal-bg: #922323;
  --color-prettylights-syntax-carriage-return-text: #cdd9e5;
  --color-prettylights-syntax-carriage-return-bg: #ad2e2c;
  --color-prettylights-syntax-string-regexp: #8ddb8c;
  --color-prettylights-syntax-markup-list: #eac55f;
  --color-prettylights-syntax-markup-heading: #316dca;
  --color-prettylights-syntax-markup-italic: #adbac7;
  --color-prettylights-syntax-markup-bold: #adbac7;
  --color-prettylights-syntax-markup-deleted-text: #ffd8d3;
  --color-prettylights-syntax-markup-deleted-bg: #78191b;
  --color-prettylights-syntax-markup-inserted-text: #b4f1b4;
  --color-prettylights-syntax-markup-inserted-bg: #1b4721;
  --color-prettylights-syntax-markup-changed-text: #ffddb0;
  --color-prettylights-syntax-markup-changed-bg: #682d0f;
  --color-prettylights-syntax-markup-ignored-text: #adbac7;
  --color-prettylights-syntax-markup-ignored-bg: #255ab2;
  --color-prettylights-syntax-meta-diff-range: #dcbdfb;
  --color-prettylights-syntax-brackethighlighter-angle: #768390;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #545d68;
  --color-prettylights-syntax-constant-other-reference-link: #96d0ff;
  --color-fg-default: #adbac7;
  --color-fg-muted: #768390;
  --color-fg-subtle: #636e7b;
  --color-canvas-default: #22272e;
  --color-canvas-subtle: #2d333b;
  --color-border-default: #444c56;
  --color-border-muted: #373e47;
  --color-neutral-muted: rgba(99,110,123,0.4);
  --color-accent-fg: #539bf5;
  --color-accent-emphasis: #316dca;
  --color-attention-subtle: rgba(174,124,20,0.15);
  --color-danger-fg: #e5534b;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=dark_dimmed] {
  /*dark_dimmed*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #768390;
  --color-prettylights-syntax-constant: #6cb6ff;
  --color-prettylights-syntax-entity: #dcbdfb;
  --color-prettylights-syntax-storage-modifier-import: #adbac7;
  --color-prettylights-syntax-entity-tag: #8ddb8c;
  --color-prettylights-syntax-keyword: #f47067;
  --color-prettylights-syntax-string: #96d0ff;
  --color-prettylights-syntax-variable: #f69d50;
  --color-prettylights-syntax-brackethighlighter-unmatched: #e5534b;
  --color-prettylights-syntax-invalid-illegal-text: #cdd9e5;
  --color-prettylights-syntax-invalid-illegal-bg: #922323;
  --color-prettylights-syntax-carriage-return-text: #cdd9e5;
  --color-prettylights-syntax-carriage-return-bg: #ad2e2c;
  --color-prettylights-syntax-string-regexp: #8ddb8c;
  --color-prettylights-syntax-markup-list: #eac55f;
  --color-prettylights-syntax-markup-heading: #316dca;
  --color-prettylights-syntax-markup-italic: #adbac7;
  --color-prettylights-syntax-markup-bold: #adbac7;
  --color-prettylights-syntax-markup-deleted-text: #ffd8d3;
  --color-prettylights-syntax-markup-deleted-bg: #78191b;
  --color-prettylights-syntax-markup-inserted-text: #b4f1b4;
  --color-prettylights-syntax-markup-inserted-bg: #1b4721;
  --color-prettylights-syntax-markup-changed-text: #ffddb0;
  --color-prettylights-syntax-markup-changed-bg: #682d0f;
  --color-prettylights-syntax-markup-ignored-text: #adbac7;
  --color-prettylights-syntax-markup-ignored-bg: #255ab2;
  --color-prettylights-syntax-meta-diff-range: #dcbdfb;
  --color-prettylights-syntax-brackethighlighter-angle: #768390;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #545d68;
  --color-prettylights-syntax-constant-other-reference-link: #96d0ff;
  --color-fg-default: #adbac7;
  --color-fg-muted: #768390;
  --color-fg-subtle: #636e7b;
  --color-canvas-default: #22272e;
  --color-canvas-subtle: #2d333b;
  --color-border-default: #444c56;
  --color-border-muted: #373e47;
  --color-neutral-muted: rgba(99,110,123,0.4);
  --color-accent-fg: #539bf5;
  --color-accent-emphasis: #316dca;
  --color-attention-subtle: rgba(174,124,20,0.15);
  --color-danger-fg: #e5534b;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=dark_colorblind],
[data-color-mode=dark][data-dark-theme=dark_colorblind],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=dark_colorblind],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=dark_colorblind] {
  /*dark_colorblind*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ec8e2c;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #fdac54;
  --color-prettylights-syntax-brackethighlighter-unmatched: #d47616;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #6c3906;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #914d04;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffe2bb;
  --color-prettylights-syntax-markup-deleted-bg: #4e2906;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffe2bb;
  --color-prettylights-syntax-markup-changed-bg: #4e2906;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #d47616;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=dark_colorblind] {
  /*dark_colorblind*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ec8e2c;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #fdac54;
  --color-prettylights-syntax-brackethighlighter-unmatched: #d47616;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #6c3906;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #914d04;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffe2bb;
  --color-prettylights-syntax-markup-deleted-bg: #4e2906;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffe2bb;
  --color-prettylights-syntax-markup-changed-bg: #4e2906;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #d47616;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=dark_colorblind] {
  /*dark_colorblind*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ec8e2c;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #fdac54;
  --color-prettylights-syntax-brackethighlighter-unmatched: #d47616;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #6c3906;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #914d04;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffe2bb;
  --color-prettylights-syntax-markup-deleted-bg: #4e2906;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffe2bb;
  --color-prettylights-syntax-markup-changed-bg: #4e2906;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #d47616;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=dark_tritanopia],
[data-color-mode=dark][data-dark-theme=dark_tritanopia],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=dark_tritanopia],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=dark_tritanopia] {
  /*dark_tritanopia*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa198;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffdcd7;
  --color-prettylights-syntax-markup-changed-bg: #67060c;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=dark_tritanopia] {
  /*dark_tritanopia*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa198;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffdcd7;
  --color-prettylights-syntax-markup-changed-bg: #67060c;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=dark_tritanopia] {
  /*dark_tritanopia*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #8b949e;
  --color-prettylights-syntax-constant: #79c0ff;
  --color-prettylights-syntax-entity: #d2a8ff;
  --color-prettylights-syntax-storage-modifier-import: #c9d1d9;
  --color-prettylights-syntax-entity-tag: #a5d6ff;
  --color-prettylights-syntax-keyword: #ff7b72;
  --color-prettylights-syntax-string: #a5d6ff;
  --color-prettylights-syntax-variable: #ffa198;
  --color-prettylights-syntax-brackethighlighter-unmatched: #f85149;
  --color-prettylights-syntax-invalid-illegal-text: #f0f6fc;
  --color-prettylights-syntax-invalid-illegal-bg: #8e1519;
  --color-prettylights-syntax-carriage-return-text: #f0f6fc;
  --color-prettylights-syntax-carriage-return-bg: #b62324;
  --color-prettylights-syntax-string-regexp: #a5d6ff;
  --color-prettylights-syntax-markup-list: #f2cc60;
  --color-prettylights-syntax-markup-heading: #1f6feb;
  --color-prettylights-syntax-markup-italic: #c9d1d9;
  --color-prettylights-syntax-markup-bold: #c9d1d9;
  --color-prettylights-syntax-markup-deleted-text: #ffdcd7;
  --color-prettylights-syntax-markup-deleted-bg: #67060c;
  --color-prettylights-syntax-markup-inserted-text: #cae8ff;
  --color-prettylights-syntax-markup-inserted-bg: #0c2d6b;
  --color-prettylights-syntax-markup-changed-text: #ffdcd7;
  --color-prettylights-syntax-markup-changed-bg: #67060c;
  --color-prettylights-syntax-markup-ignored-text: #c9d1d9;
  --color-prettylights-syntax-markup-ignored-bg: #1158c7;
  --color-prettylights-syntax-meta-diff-range: #d2a8ff;
  --color-prettylights-syntax-brackethighlighter-angle: #8b949e;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #484f58;
  --color-prettylights-syntax-constant-other-reference-link: #a5d6ff;
  --color-fg-default: #c9d1d9;
  --color-fg-muted: #8b949e;
  --color-fg-subtle: #6e7681;
  --color-canvas-default: #0d1117;
  --color-canvas-subtle: #161b22;
  --color-border-default: #30363d;
  --color-border-muted: #21262d;
  --color-neutral-muted: rgba(110,118,129,0.4);
  --color-accent-fg: #58a6ff;
  --color-accent-emphasis: #1f6feb;
  --color-attention-subtle: rgba(187,128,9,0.15);
  --color-danger-fg: #f85149;
}
}
</style>
<style>[data-color-mode=light][data-light-theme=dark_high_contrast],
[data-color-mode=dark][data-dark-theme=dark_high_contrast],
.vscode-body.vscode-light [data-color-mode=auto][data-light-theme=dark_high_contrast],
.vscode-body.vscode-dark [data-color-mode=auto][data-dark-theme=dark_high_contrast] {
  /*dark_high_contrast*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #bdc4cc;
  --color-prettylights-syntax-constant: #91cbff;
  --color-prettylights-syntax-entity: #dbb7ff;
  --color-prettylights-syntax-storage-modifier-import: #f0f3f6;
  --color-prettylights-syntax-entity-tag: #72f088;
  --color-prettylights-syntax-keyword: #ff9492;
  --color-prettylights-syntax-string: #addcff;
  --color-prettylights-syntax-variable: #ffb757;
  --color-prettylights-syntax-brackethighlighter-unmatched: #ff6a69;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #e82a2f;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #ff4445;
  --color-prettylights-syntax-string-regexp: #72f088;
  --color-prettylights-syntax-markup-list: #fbd669;
  --color-prettylights-syntax-markup-heading: #409eff;
  --color-prettylights-syntax-markup-italic: #f0f3f6;
  --color-prettylights-syntax-markup-bold: #f0f3f6;
  --color-prettylights-syntax-markup-deleted-text: #ffdedb;
  --color-prettylights-syntax-markup-deleted-bg: #cc1421;
  --color-prettylights-syntax-markup-inserted-text: #acf7b6;
  --color-prettylights-syntax-markup-inserted-bg: #007728;
  --color-prettylights-syntax-markup-changed-text: #ffe1b4;
  --color-prettylights-syntax-markup-changed-bg: #a74c00;
  --color-prettylights-syntax-markup-ignored-text: #f0f3f6;
  --color-prettylights-syntax-markup-ignored-bg: #318bf8;
  --color-prettylights-syntax-meta-diff-range: #dbb7ff;
  --color-prettylights-syntax-brackethighlighter-angle: #bdc4cc;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #7a828e;
  --color-prettylights-syntax-constant-other-reference-link: #addcff;
  --color-fg-default: #f0f3f6;
  --color-fg-muted: #f0f3f6;
  --color-fg-subtle: #9ea7b3;
  --color-canvas-default: #0a0c10;
  --color-canvas-subtle: #272b33;
  --color-border-default: #7a828e;
  --color-border-muted: #7a828e;
  --color-neutral-muted: rgba(158,167,179,0.4);
  --color-accent-fg: #71b7ff;
  --color-accent-emphasis: #409eff;
  --color-attention-subtle: rgba(224,155,19,0.15);
  --color-danger-fg: #ff6a69;
}
@media (prefers-color-scheme: light) {
  [data-color-mode='system'][data-light-theme=dark_high_contrast] {
  /*dark_high_contrast*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #bdc4cc;
  --color-prettylights-syntax-constant: #91cbff;
  --color-prettylights-syntax-entity: #dbb7ff;
  --color-prettylights-syntax-storage-modifier-import: #f0f3f6;
  --color-prettylights-syntax-entity-tag: #72f088;
  --color-prettylights-syntax-keyword: #ff9492;
  --color-prettylights-syntax-string: #addcff;
  --color-prettylights-syntax-variable: #ffb757;
  --color-prettylights-syntax-brackethighlighter-unmatched: #ff6a69;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #e82a2f;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #ff4445;
  --color-prettylights-syntax-string-regexp: #72f088;
  --color-prettylights-syntax-markup-list: #fbd669;
  --color-prettylights-syntax-markup-heading: #409eff;
  --color-prettylights-syntax-markup-italic: #f0f3f6;
  --color-prettylights-syntax-markup-bold: #f0f3f6;
  --color-prettylights-syntax-markup-deleted-text: #ffdedb;
  --color-prettylights-syntax-markup-deleted-bg: #cc1421;
  --color-prettylights-syntax-markup-inserted-text: #acf7b6;
  --color-prettylights-syntax-markup-inserted-bg: #007728;
  --color-prettylights-syntax-markup-changed-text: #ffe1b4;
  --color-prettylights-syntax-markup-changed-bg: #a74c00;
  --color-prettylights-syntax-markup-ignored-text: #f0f3f6;
  --color-prettylights-syntax-markup-ignored-bg: #318bf8;
  --color-prettylights-syntax-meta-diff-range: #dbb7ff;
  --color-prettylights-syntax-brackethighlighter-angle: #bdc4cc;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #7a828e;
  --color-prettylights-syntax-constant-other-reference-link: #addcff;
  --color-fg-default: #f0f3f6;
  --color-fg-muted: #f0f3f6;
  --color-fg-subtle: #9ea7b3;
  --color-canvas-default: #0a0c10;
  --color-canvas-subtle: #272b33;
  --color-border-default: #7a828e;
  --color-border-muted: #7a828e;
  --color-neutral-muted: rgba(158,167,179,0.4);
  --color-accent-fg: #71b7ff;
  --color-accent-emphasis: #409eff;
  --color-attention-subtle: rgba(224,155,19,0.15);
  --color-danger-fg: #ff6a69;
}
}

@media (prefers-color-scheme: dark) {
  [data-color-mode='system'][data-dark-theme=dark_high_contrast] {
  /*dark_high_contrast*/
  color-scheme: dark;
  --color-prettylights-syntax-comment: #bdc4cc;
  --color-prettylights-syntax-constant: #91cbff;
  --color-prettylights-syntax-entity: #dbb7ff;
  --color-prettylights-syntax-storage-modifier-import: #f0f3f6;
  --color-prettylights-syntax-entity-tag: #72f088;
  --color-prettylights-syntax-keyword: #ff9492;
  --color-prettylights-syntax-string: #addcff;
  --color-prettylights-syntax-variable: #ffb757;
  --color-prettylights-syntax-brackethighlighter-unmatched: #ff6a69;
  --color-prettylights-syntax-invalid-illegal-text: #ffffff;
  --color-prettylights-syntax-invalid-illegal-bg: #e82a2f;
  --color-prettylights-syntax-carriage-return-text: #ffffff;
  --color-prettylights-syntax-carriage-return-bg: #ff4445;
  --color-prettylights-syntax-string-regexp: #72f088;
  --color-prettylights-syntax-markup-list: #fbd669;
  --color-prettylights-syntax-markup-heading: #409eff;
  --color-prettylights-syntax-markup-italic: #f0f3f6;
  --color-prettylights-syntax-markup-bold: #f0f3f6;
  --color-prettylights-syntax-markup-deleted-text: #ffdedb;
  --color-prettylights-syntax-markup-deleted-bg: #cc1421;
  --color-prettylights-syntax-markup-inserted-text: #acf7b6;
  --color-prettylights-syntax-markup-inserted-bg: #007728;
  --color-prettylights-syntax-markup-changed-text: #ffe1b4;
  --color-prettylights-syntax-markup-changed-bg: #a74c00;
  --color-prettylights-syntax-markup-ignored-text: #f0f3f6;
  --color-prettylights-syntax-markup-ignored-bg: #318bf8;
  --color-prettylights-syntax-meta-diff-range: #dbb7ff;
  --color-prettylights-syntax-brackethighlighter-angle: #bdc4cc;
  --color-prettylights-syntax-sublimelinter-gutter-mark: #7a828e;
  --color-prettylights-syntax-constant-other-reference-link: #addcff;
  --color-fg-default: #f0f3f6;
  --color-fg-muted: #f0f3f6;
  --color-fg-subtle: #9ea7b3;
  --color-canvas-default: #0a0c10;
  --color-canvas-subtle: #272b33;
  --color-border-default: #7a828e;
  --color-border-muted: #7a828e;
  --color-neutral-muted: rgba(158,167,179,0.4);
  --color-accent-fg: #71b7ff;
  --color-accent-emphasis: #409eff;
  --color-attention-subtle: rgba(224,155,19,0.15);
  --color-danger-fg: #ff6a69;
}
}
</style>
<style>/*!
  Theme: GitHub
  Description: Highlight-js port of github.com theme
  Author: github.com
  Maintainer: @SNDST00M, @mjbvz
  Updated: 2021-12-08
*/
.markdown-body pre code.hljs {
  display: block;
  overflow-x: auto;
  padding: 16px;
}

.markdown-body code.hljs {
  padding: 3px 5px;
}

/*!
  Theme: GitHub
  Description: Theme as seen on github.com
  Author: github.com
  Maintainer: @Hirse
  Updated: 2021-05-15

  Outdated base version: https://github.com/primer/github-syntax-dark
  Current colors taken from GitHub's CSS
*/
.markdown-body .hljs {
  color: var(--color-fg-default);
  background: var(--color-canvas-subtle);
}

.markdown-body .hljs-doctag,
.markdown-body .hljs-keyword,
.markdown-body .hljs-meta .hljs-keyword,
.markdown-body .hljs-template-tag,
.markdown-body .hljs-template-variable,
.markdown-body .hljs-type,
.markdown-body .hljs-variable.language_ {
  color: var(--color-prettylights-syntax-keyword);
}

.markdown-body .hljs-title,
.markdown-body .hljs-title.class_,
.markdown-body .hljs-title.class_.inherited__,
.markdown-body .hljs-title.function_ {
  color: var(--color-prettylights-syntax-entity);
}

.markdown-body .hljs-attr,
.markdown-body .hljs-attribute,
.markdown-body .hljs-literal,
.markdown-body .hljs-meta,
.markdown-body .hljs-number,
.markdown-body .hljs-operator,
.markdown-body .hljs-selector-attr,
.markdown-body .hljs-selector-class,
.markdown-body .hljs-selector-id,
.markdown-body .hljs-variable {
  color: var(--color-prettylights-syntax-constant);
}

.markdown-body .hljs-meta .hljs-string,
.markdown-body .hljs-regexp,
.markdown-body .hljs-string {
  color: var(--color-prettylights-syntax-string);
}

.markdown-body .hljs-built_in,
.markdown-body .hljs-symbol {
  color: var(--color-prettylights-syntax-variable);
}

.markdown-body .hljs-code,
.markdown-body .hljs-comment,
.markdown-body .hljs-formula {
  color: var(--color-prettylights-syntax-comment);
}

.markdown-body .hljs-name,
.markdown-body .hljs-quote,
.markdown-body .hljs-selector-pseudo,
.markdown-body .hljs-selector-tag {
  color: var(--color-prettylights-syntax-entity-tag);
}

.markdown-body .hljs-subst {
  color: var(--color-prettylights-syntax-constant);
}

.markdown-body .hljs-section {
  color: var(--color-prettylights-syntax-markup-heading);
  font-weight: bold;
}

.markdown-body .hljs-bullet {
  color: var(--color-prettylights-syntax-markup-list);
}

.markdown-body .hljs-emphasis {
  color: var(--color-prettylights-syntax-constant);
  font-style: italic;
}

.markdown-body .hljs-strong {
  color: var(--color-prettylights-syntax-constant);
  font-weight: bold;
}

.markdown-body .hljs-addition {
  color: var(--color-prettylights-syntax-markup-inserted-text);
  background-color: var(--color-prettylights-syntax-markup-inserted-bg);
}

.markdown-body .hljs-deletion {
  color: var(--color-prettylights-syntax-markup-deleted-text);
  background-color: var(--color-prettylights-syntax-markup-deleted-bg);
}
</style>

    </head>
    <body class="vscode-body vscode-light">
        <div class="github-markdown-body" data-color-mode="auto" data-light-theme="light_tritanopia" data-dark-theme="dark_colorblind">
            <div class="github-markdown-content"><h2 data-line="0" class="code-line" dir="auto" id="0pipeline_test" tabindex="-1">0.pipeline_test</h2>
<pre><code data-line="1" class="code-line language-python" dir="auto"><div>pipeline {
  agent <span class="hljs-built_in">any</span>
  stages {
      stage(<span class="hljs-string">'execute ls command'</span>) {
        steps {
          echo <span class="hljs-string">'execute ls command'</span>
          sh <span class="hljs-string">'ls -la'</span>
        }
      }
      stage(<span class="hljs-string">'Where do ls command execute?'</span>) {
        steps {
          echo <span class="hljs-string">'Here is default.'</span>
          sh <span class="hljs-string">'ls -la'</span>
          echo <span class="hljs-string">'you can define where to execute command.'</span>
          echo <span class="hljs-string">'For example, I want to view root directory'</span>
          sh <span class="hljs-string">'ls -la /'</span>
        }
      }
      stage(<span class="hljs-string">'Is there any other way?'</span>) {
        steps {
          echo <span class="hljs-string">'Maybe sh is independent'</span>
          sh <span class="hljs-string">'cd /'</span>
          sh <span class="hljs-string">'pwd'</span>
          sh <span class="hljs-string">'ls -la'</span>
          echo <span class="hljs-string">'If you want to execute multiple commands in one sh.'</span>
          sh <span class="hljs-string">'''cd /
          pwd
          ls -la'''</span>
        }
      }
    }
  }
</div></code></pre>
<h2 data-line="38" class="code-line" dir="auto" id="1pipeline_syntax_if_test" tabindex="-1">1.pipeline_syntax_if_test</h2>
<pre><code data-line="39" class="code-line language-python" dir="auto"><div>pipeline{
    agent{
		label <span class="hljs-string">'slave'</span>
	}
    stages{
        stage(<span class="hljs-string">'var check'</span>){
            steps{
                script{
                    var1 = sh(script: <span class="hljs-string">'ls -l | wc -l'</span>, returnStdout: true).trim()
                }
				
                echo <span class="hljs-string">'${var1}'</span>
                sh <span class="hljs-string">"""pwd
				   ls -l
				   echo ${var1}"""</span>
            }
        }
        stage(<span class="hljs-string">'if check'</span>){
            steps{
				echo <span class="hljs-string">"aa"</span>
                script{
                    var1 = sh(script: <span class="hljs-string">'ls -l | wc -l'</span>, returnStdout: true).trim()
					sh <span class="hljs-string">"echo ${var1}"</span>
                    <span class="hljs-keyword">if</span>(var1&gt;=<span class="hljs-number">1</span>){
                        sh <span class="hljs-string">"echo \'ok(${var1})\'"</span>
                    }
                    <span class="hljs-keyword">else</span>{
                         sh <span class="hljs-string">"echo \'no(${var1})\'"</span>
                    }
                }
                
            }
        }
    }
    
}
</div></code></pre>
<h2 data-line="78" class="code-line" dir="auto" id="2dockerfile_webhook_deploy" tabindex="-1">2.Dockerfile_Webhook_Deploy</h2>
<pre><code data-line="79" class="code-line language-python" dir="auto"><div>pipeline {
	agent {
		label <span class="hljs-string">'slave'</span>    
	}
	stages {
		stage(<span class="hljs-string">'Check Path'</span>) {
			steps {
				sh <span class="hljs-string">'''hostname 
					  hostname -i 
					  pwd
					  docker image ls
					  '''</span>
				script{
				    chck = sh(script: <span class="hljs-string">'docker container ls --all | grep web_test | wc -l'</span>, returnStdout: true).trim()
				    <span class="hljs-keyword">if</span>(chck&gt;=<span class="hljs-number">1</span>){
				        sh <span class="hljs-string">"docker rm web_test -f"</span>
				    }
				}
			}
		}
		stage(<span class="hljs-string">'Checkout'</span>) {
			steps {
				git branch: <span class="hljs-string">'master'</span>,
					credentialsId: <span class="hljs-string">'gitlab-token'</span>,
					url: <span class="hljs-string">'https://testdomainname.info/wocheon/docker_images.git'</span>
			}
		}
		stage(<span class="hljs-string">'Build'</span>) {
			steps {
	               sh <span class="hljs-string">'''docker build -t web_test .
	                    docker image ls | grep web_test'''</span>
			}
		}
		stage(<span class="hljs-string">'Deploy'</span>) {
			steps {
				sh <span class="hljs-string">'''docker build -t web_test .
					docker run -d -p 80:80 --name web_test web_test
					docker container ls 
					curl localhost					
				   '''</span>
			}
		}
	}
}
</div></code></pre>
<h2 data-line="127" class="code-line" dir="auto" id="3mvn_build_test" tabindex="-1">3.mvn_build_test</h2>
<h3 data-line="128" class="code-line" dir="auto" id="maven-project" tabindex="-1">Maven Project</h3>
<ul data-line="129" class="code-line" dir="auto">
<li data-line="129" class="code-line" dir="auto">
<p data-line="129" class="code-line" dir="auto">General</p>
<ul data-line="130" class="code-line" dir="auto">
<li data-line="130" class="code-line" dir="auto">GitLab Connection : gitlab_connect (System)</li>
</ul>
</li>
<li data-line="131" class="code-line" dir="auto">
<p data-line="131" class="code-line" dir="auto">소스 코드 관리</p>
<ul data-line="132" class="code-line" dir="auto">
<li data-line="132" class="code-line" dir="auto">Repository URL : <a href="https://testdomainname.info/wocheon/mvn_project.git" data-href="https://testdomainname.info/wocheon/mvn_project.git">https://testdomainname.info/wocheon/mvn_project.git</a></li>
<li data-line="133" class="code-line" dir="auto">Credentials : - none -</li>
<li data-line="134" class="code-line" dir="auto">Branches to build
<ul data-line="135" class="code-line" dir="auto">
<li data-line="135" class="code-line" dir="auto">Branch Specifier (blank for 'any') : */main</li>
</ul>
</li>
</ul>
</li>
<li data-line="137" class="code-line" dir="auto">
<p data-line="137" class="code-line" dir="auto">Build Steps</p>
<ul data-line="138" class="code-line" dir="auto">
<li data-line="138" class="code-line" dir="auto">Maven Version : maven_home (ToolS)</li>
<li data-line="139" class="code-line" dir="auto">Goals : clean package</li>
</ul>
</li>
</ul>
<h3 data-line="141" class="code-line" dir="auto" id="system--credentials" tabindex="-1">System &amp; Credentials</h3>
<blockquote data-line="142" class="code-line" dir="auto">
<p data-line="142" class="code-line" dir="auto">System</p>
</blockquote>
<ul data-line="144" class="code-line" dir="auto">
<li data-line="144" class="code-line" dir="auto"><code>gitlab_connect</code>
<ul data-line="145" class="code-line" dir="auto">
<li data-line="145" class="code-line" dir="auto">GitLab
<ul data-line="146" class="code-line" dir="auto">
<li data-line="146" class="code-line" dir="auto">GitLab connections
<ul data-line="147" class="code-line" dir="auto">
<li data-line="147" class="code-line" dir="auto">Connection name : gitlab_connect</li>
<li data-line="148" class="code-line" dir="auto">GitLab host URL : <a href="https://testdomainname.info" data-href="https://testdomainname.info">https://testdomainname.info</a></li>
<li data-line="149" class="code-line" dir="auto">Credentials : GitLab API token (gitlab_api_token_wocheon07) (Credential)</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
<blockquote data-line="151" class="code-line" dir="auto">
<p data-line="151" class="code-line" dir="auto">Tools</p>
</blockquote>
<ul data-line="152" class="code-line" dir="auto">
<li data-line="152" class="code-line" dir="auto"><code>maven_home</code>
<ul data-line="153" class="code-line" dir="auto">
<li data-line="153" class="code-line" dir="auto">Maven
<ul data-line="154" class="code-line" dir="auto">
<li data-line="154" class="code-line" dir="auto">Name : maven_home</li>
<li data-line="155" class="code-line" dir="auto">MAVEN_HOME : /usr/share/maven</li>
<li data-line="156" class="code-line" dir="auto">Install automatically : 체크 해제</li>
</ul>
</li>
</ul>
</li>
</ul>
<blockquote data-line="158" class="code-line" dir="auto">
<p data-line="158" class="code-line" dir="auto">Credential</p>
</blockquote>
<ul data-line="159" class="code-line" dir="auto">
<li data-line="159" class="code-line" dir="auto"><code>GitLab API token (gitlab_api_token_wocheon07)</code>
<ul data-line="160" class="code-line" dir="auto">
<li data-line="160" class="code-line" dir="auto">Scpoe : Global</li>
<li data-line="161" class="code-line" dir="auto">ID : wocheon07</li>
<li data-line="162" class="code-line" dir="auto">API token : Gitlab API Acess Token</li>
<li data-line="163" class="code-line" dir="auto">Description : gitlab_api_token_wocheon07</li>
</ul>
</li>
</ul>
<h2 data-line="165" class="code-line" dir="auto" id="4-maven_pipeline_deploy" tabindex="-1">4. Maven_Pipeline_Deploy</h2>
<pre><code data-line="167" class="code-line language-python" dir="auto"><div>pipeline {
	agent {
		label <span class="hljs-string">'slave'</span>    
	}
	stages {
		stage(<span class="hljs-string">'Check Current Path'</span>) {
			steps {
				sh <span class="hljs-string">'''hostname 
					  hostname -i 
					  pwd
					  ls -lrth
					  '''</span>
			}
		}
		stage(<span class="hljs-string">'Gitlab Checkout'</span>) {
			steps {
				git branch: <span class="hljs-string">'main'</span>,
					credentialsId: <span class="hljs-string">'mvn_project'</span>,
					url: <span class="hljs-string">'https://testdomainname.info/wocheon/mvn_project.git'</span>
				sh <span class="hljs-string">'ls -lrth'</span>
			}
		}		
		stage(<span class="hljs-string">'Build_Warfile'</span>) {
			steps {
				sh <span class="hljs-string">'''
					mvn clean package
					cd target
					mv test.war ROOT.war
					ls -lrth 
					 '''</span>
			}
		}								
		stage(<span class="hljs-string">'Build_Dockerfile'</span>) {
			steps {
				sh <span class="hljs-string">'''
					pwd
					ls -lrth
					docker build -t web-app .
					docker image ls
				   '''</span>
			}
		}						
		stage(<span class="hljs-string">'Deploy'</span>) {
			steps {
				sh <span class="hljs-string">'''
				    docker rm web-app -f
					docker run -d -it -p 8090:8080 --name web-app web-app
					docker container ls -a
					sleep 3
					curl localhost:8090					
				   '''</span>
			}
		}
	}
}
</div></code></pre>
</div>
        </div>
        <script>var Be=(e,t)=>()=>(t||e((t={exports:{}}).exports,t),t.exports);var Me=Be((Lt,Ne)=>{var xe="Expected a function",Ae=NaN,Qe="[object Symbol]",Ze=/^\s+|\s+$/g,et=/^[-+]0x[0-9a-f]+$/i,tt=/^0b[01]+$/i,nt=/^0o[0-7]+$/i,rt=parseInt,it=typeof global=="object"&&global&&global.Object===Object&&global,at=typeof self=="object"&&self&&self.Object===Object&&self,ot=it||at||Function("return this")(),st=Object.prototype,lt=st.toString,ct=Math.max,ut=Math.min,ue=function(){return ot.Date.now()};function dt(e,t,n){var r,i,a,s,u,m,d=0,p=!1,b=!1,T=!0;if(typeof e!="function")throw new TypeError(xe);t=Le(t)||0,te(n)&&(p=!!n.leading,b="maxWait"in n,a=b?ct(Le(n.maxWait)||0,t):a,T="trailing"in n?!!n.trailing:T);function E(v){var A=r,_=i;return r=i=void 0,d=v,s=e.apply(_,A),s}function N(v){return d=v,u=setTimeout(L,t),p?E(v):s}function g(v){var A=v-m,_=v-d,h=t-A;return b?ut(h,a-_):h}function S(v){var A=v-m,_=v-d;return m===void 0||A>=t||A<0||b&&_>=a}function L(){var v=ue();if(S(v))return U(v);u=setTimeout(L,g(v))}function U(v){return u=void 0,T&&r?E(v):(r=i=void 0,s)}function R(){u!==void 0&&clearTimeout(u),d=0,r=m=i=u=void 0}function Y(){return u===void 0?s:U(ue())}function I(){var v=ue(),A=S(v);if(r=arguments,i=this,m=v,A){if(u===void 0)return N(m);if(b)return u=setTimeout(L,t),E(m)}return u===void 0&&(u=setTimeout(L,t)),s}return I.cancel=R,I.flush=Y,I}function ft(e,t,n){var r=!0,i=!0;if(typeof e!="function")throw new TypeError(xe);return te(n)&&(r="leading"in n?!!n.leading:r,i="trailing"in n?!!n.trailing:i),dt(e,t,{leading:r,maxWait:t,trailing:i})}function te(e){var t=typeof e;return!!e&&(t=="object"||t=="function")}function mt(e){return!!e&&typeof e=="object"}function gt(e){return typeof e=="symbol"||mt(e)&&lt.call(e)==Qe}function Le(e){if(typeof e=="number")return e;if(gt(e))return Ae;if(te(e)){var t=typeof e.valueOf=="function"?e.valueOf():e;e=te(t)?t+"":t}if(typeof e!="string")return e===0?e:+e;e=e.replace(Ze,"");var n=tt.test(e);return n||nt.test(e)?rt(e.slice(2),n?2:8):et.test(e)?Ae:+e}Ne.exports=ft});var pe="code-line",F=class{constructor(t,n,r){this.element=t;this.line=n;this.codeElement=r;this._detailParentElements=Array.from(Re(t,"DETAILS"))}get isVisible(){return!this._detailParentElements.some(t=>!t.open)}},ae=(()=>{let e,t=-1;return n=>{if(!e||n!==t){t=n,e=[new F(document.body,-1)];for(let r of document.getElementsByClassName(pe)){if(!(r instanceof HTMLElement))continue;let i=+r.getAttribute("data-line");isNaN(i)||(r.tagName==="CODE"&&r.parentElement&&r.parentElement.tagName==="PRE"?e.push(new F(r.parentElement,i,r)):r.tagName==="UL"||r.tagName==="OL"||e.push(new F(r,i)))}}return e}})();function oe(e,t){let n=Math.floor(e),r=ae(t),i=r[0]||null;for(let a of r){if(a.line===n)return{previous:a,next:void 0};if(a.line>n)return{previous:i,next:a};i=a}return{previous:i}}function He(e,t){let n=ae(t).filter(m=>m.isVisible),r=e-window.scrollY,i=-1,a=n.length-1;for(;i+1<a;){let m=Math.floor((i+a)/2),d=W(n[m]);d.top+d.height>=r?a=m:i=m}let s=n[a],u=W(s);return a>=1&&u.top>r?{previous:n[i],next:s}:a>1&&a<n.length&&u.top+u.height>r?{previous:s,next:n[a+1]}:{previous:s}}function W({element:e}){let t=e.getBoundingClientRect(),n=e.querySelector(`.${pe}`);if(n){let r=n.getBoundingClientRect(),i=Math.max(1,r.top-t.top);return{top:t.top,height:i}}return t}function K(e,t,n){if(!n.settings?.scrollPreviewWithEditor)return;if(e<=0){window.scroll(window.scrollX,0);return}let{previous:r,next:i}=oe(e,t);if(!r)return;let a=0,s=W(r),u=s.top;if(i&&i.line!==r.line){let m=(e-r.line)/(i.line-r.line),d=u+s.height,p=i.element.getBoundingClientRect().top-d;a=d+m*p}else{let m=e-Math.floor(e);a=u+s.height*m}a=Math.abs(a)<1?Math.sign(a):a,window.scroll(window.scrollX,Math.max(1,window.scrollY+a))}function se(e,t){let{previous:n,next:r}=He(e,t);if(n){if(n.line<0)return 0;let i=W(n),a=e-window.scrollY-i.top;if(r){let s=a/(W(r).top-i.top);return n.line+s*(r.line-n.line)}else{let s=a/i.height;return n.line+s}}return null}function ve(e,t){return ae(t).find(n=>n.element.id===e)}function*Re(e,t){for(let n=e.parentElement;n;n=n.parentElement)n.tagName===t&&(yield n)}var J=class{onDidChangeTextEditorSelection(t,n){let{previous:r}=oe(t,n);this._update(r&&(r.codeElement||r.element))}_update(t){this._unmarkActiveElement(this._current),this._markActiveElement(t),this._current=t}_unmarkActiveElement(t){t&&t.classList.toggle("code-active-line",!1)}_markActiveElement(t){t&&t.classList.toggle("code-active-line",!0)}};function he(e){document.readyState==="loading"||document.readyState==="uninitialized"?document.addEventListener("DOMContentLoaded",e):e()}var be=(e,t)=>({postMessage(n,r){e.postMessage({type:n,source:t.settings.source,...r})}});function le(e){let t=document.getElementById("vscode-markdown-preview-data");if(t){let n=t.getAttribute(e);if(n)return JSON.parse(n)}throw new Error(`Could not load data for ${e}`)}var Q=class{constructor(){this._settings=le("data-settings")}get settings(){return this._settings}updateSettings(t){this._settings=t}};var ye=11;function ke(e,t){var n=t.attributes,r,i,a,s,u;if(!(t.nodeType===ye||e.nodeType===ye)){for(var m=n.length-1;m>=0;m--)r=n[m],i=r.name,a=r.namespaceURI,s=r.value,a?(i=r.localName||i,u=e.getAttributeNS(a,i),u!==s&&(r.prefix==="xmlns"&&(i=r.name),e.setAttributeNS(a,i,s))):(u=e.getAttribute(i),u!==s&&e.setAttribute(i,s));for(var d=e.attributes,p=d.length-1;p>=0;p--)r=d[p],i=r.name,a=r.namespaceURI,a?(i=r.localName||i,t.hasAttributeNS(a,i)||e.removeAttributeNS(a,i)):t.hasAttribute(i)||e.removeAttribute(i)}}var Z,Ue="http://www.w3.org/1999/xhtml",w=typeof document>"u"?void 0:document,Fe=!!w&&"content"in w.createElement("template"),We=!!w&&w.createRange&&"createContextualFragment"in w.createRange();function Ve(e){var t=w.createElement("template");return t.innerHTML=e,t.content.childNodes[0]}function je(e){Z||(Z=w.createRange(),Z.selectNode(w.body));var t=Z.createContextualFragment(e);return t.childNodes[0]}function qe(e){var t=w.createElement("body");return t.innerHTML=e,t.childNodes[0]}function Xe(e){return e=e.trim(),Fe?Ve(e):We?je(e):qe(e)}function ee(e,t){var n=e.nodeName,r=t.nodeName,i,a;return n===r?!0:(i=n.charCodeAt(0),a=r.charCodeAt(0),i<=90&&a>=97?n===r.toUpperCase():a<=90&&i>=97?r===n.toUpperCase():!1)}function Ye(e,t){return!t||t===Ue?w.createElement(e):w.createElementNS(t,e)}function ze(e,t){for(var n=e.firstChild;n;){var r=n.nextSibling;t.appendChild(n),n=r}return t}function ce(e,t,n){e[n]!==t[n]&&(e[n]=t[n],e[n]?e.setAttribute(n,""):e.removeAttribute(n))}var Te={OPTION:function(e,t){var n=e.parentNode;if(n){var r=n.nodeName.toUpperCase();r==="OPTGROUP"&&(n=n.parentNode,r=n&&n.nodeName.toUpperCase()),r==="SELECT"&&!n.hasAttribute("multiple")&&(e.hasAttribute("selected")&&!t.selected&&(e.setAttribute("selected","selected"),e.removeAttribute("selected")),n.selectedIndex=-1)}ce(e,t,"selected")},INPUT:function(e,t){ce(e,t,"checked"),ce(e,t,"disabled"),e.value!==t.value&&(e.value=t.value),t.hasAttribute("value")||e.removeAttribute("value")},TEXTAREA:function(e,t){var n=t.value;e.value!==n&&(e.value=n);var r=e.firstChild;if(r){var i=r.nodeValue;if(i==n||!n&&i==e.placeholder)return;r.nodeValue=n}},SELECT:function(e,t){if(!t.hasAttribute("multiple")){for(var n=-1,r=0,i=e.firstChild,a,s;i;)if(s=i.nodeName&&i.nodeName.toUpperCase(),s==="OPTGROUP")a=i,i=a.firstChild;else{if(s==="OPTION"){if(i.hasAttribute("selected")){n=r;break}r++}i=i.nextSibling,!i&&a&&(i=a.nextSibling,a=null)}e.selectedIndex=n}}},V=1,Ge=11,we=3,Ee=8;function B(){}function $e(e){if(e)return e.getAttribute&&e.getAttribute("id")||e.id}function Ke(e){return function(n,r,i){if(i||(i={}),typeof r=="string")if(n.nodeName==="#document"||n.nodeName==="HTML"||n.nodeName==="BODY"){var a=r;r=w.createElement("html"),r.innerHTML=a}else r=Xe(r);var s=i.getNodeKey||$e,u=i.onBeforeNodeAdded||B,m=i.onNodeAdded||B,d=i.onBeforeElUpdated||B,p=i.onElUpdated||B,b=i.onBeforeNodeDiscarded||B,T=i.onNodeDiscarded||B,E=i.onBeforeElChildrenUpdated||B,N=i.childrenOnly===!0,g=Object.create(null),S=[];function L(c){S.push(c)}function U(c,l){if(c.nodeType===V)for(var o=c.firstChild;o;){var f=void 0;l&&(f=s(o))?L(f):(T(o),o.firstChild&&U(o,l)),o=o.nextSibling}}function R(c,l,o){b(c)!==!1&&(l&&l.removeChild(c),T(c),U(c,o))}function Y(c){if(c.nodeType===V||c.nodeType===Ge)for(var l=c.firstChild;l;){var o=s(l);o&&(g[o]=l),Y(l),l=l.nextSibling}}Y(n);function I(c){m(c);for(var l=c.firstChild;l;){var o=l.nextSibling,f=s(l);if(f){var x=g[f];x&&ee(l,x)?(l.parentNode.replaceChild(x,l),A(x,l)):I(l)}else I(l);l=o}}function v(c,l,o){for(;l;){var f=l.nextSibling;(o=s(l))?L(o):R(l,c,!0),l=f}}function A(c,l,o){var f=s(l);f&&delete g[f],!(!o&&(d(c,l)===!1||(e(c,l),p(c),E(c,l)===!1)))&&(c.nodeName!=="TEXTAREA"?_(c,l):Te.TEXTAREA(c,l))}function _(c,l){var o=l.firstChild,f=c.firstChild,x,P,k,G,O;e:for(;o;){for(G=o.nextSibling,x=s(o);f;){if(k=f.nextSibling,o.isSameNode&&o.isSameNode(f)){o=G,f=k;continue e}P=s(f);var $=f.nodeType,D=void 0;if($===o.nodeType&&($===V?(x?x!==P&&((O=g[x])?k===O?D=!1:(c.insertBefore(O,f),P?L(P):R(f,c,!0),f=O):D=!1):P&&(D=!1),D=D!==!1&&ee(f,o),D&&A(f,o)):($===we||$==Ee)&&(D=!0,f.nodeValue!==o.nodeValue&&(f.nodeValue=o.nodeValue))),D){o=G,f=k;continue e}P?L(P):R(f,c,!0),f=k}if(x&&(O=g[x])&&ee(O,o))c.appendChild(O),A(O,o);else{var ie=u(o);ie!==!1&&(ie&&(o=ie),o.actualize&&(o=o.actualize(c.ownerDocument||w)),c.appendChild(o),I(o))}o=G,f=k}v(c,f,P);var ge=Te[c.nodeName];ge&&ge(c,l)}var h=n,z=h.nodeType,me=r.nodeType;if(!N){if(z===V)me===V?ee(n,r)||(T(n),h=ze(n,Ye(r.nodeName,r.namespaceURI))):h=r;else if(z===we||z===Ee){if(me===z)return h.nodeValue!==r.nodeValue&&(h.nodeValue=r.nodeValue),h;h=r}}if(h===r)T(n);else{if(r.isSameNode&&r.isSameNode(h))return;if(A(h,r,N),S)for(var ne=0,_e=S.length;ne<_e;ne++){var re=g[S[ne]];re&&R(re,re.parentNode,!1)}}return!N&&h!==n&&n.parentNode&&(h.actualize&&(h=h.actualize(n.ownerDocument||w)),n.parentNode.replaceChild(h,n)),h}}var Je=Ke(ke),Se=Je;var Ce=Me(),H=0,Pe=new J,y=new Q,M=0,j=y.settings.source,q=acquireVsCodeApi(),de=q.getState()??{},C={...de,...le("data-state")};typeof de.scrollProgress<"u"&&de?.resource!==C.resource&&(C.scrollProgress=0);q.setState(C);var X=be(q,y);window.cspAlerter.setPoster(X);window.styleLoadingMonitor.setPoster(X);function fe(e){let t=document.getElementsByTagName("img");if(t.length>0){let n=Array.from(t,r=>r.complete?Promise.resolve():new Promise(i=>{r.addEventListener("load",()=>i()),r.addEventListener("error",()=>i())}));Promise.all(n).then(()=>setTimeout(e,0))}else setTimeout(e,0)}he(()=>{let e=C.scrollProgress;if(Oe(),typeof e=="number"&&!y.settings.fragment){fe(()=>{H+=1;let t=Math.max(1,e*document.body.clientHeight);window.scrollTo(0,t)});return}y.settings.scrollPreviewWithEditor&&fe(()=>{if(y.settings.fragment){let t;try{t=encodeURIComponent(y.settings.fragment)}catch{t=y.settings.fragment}C.fragment=void 0,q.setState(C);let n=ve(t,M);n&&(H+=1,K(n.line,M,y))}else isNaN(y.settings.line)||(H+=1,K(y.settings.line,M,y))}),typeof y.settings.selectedLine=="number"&&Pe.onDidChangeTextEditorSelection(y.settings.selectedLine,M)});var pt=(()=>{let e=Ce(t=>{H+=1,fe(()=>K(t,M,y))},50);return t=>{isNaN(t)||(C.line=t,e(t))}})();window.addEventListener("resize",()=>{H+=1,Ie()},!0);function Oe(){let e=document.getElementsByTagName("img"),t=0;for(let n of e)n.id="image-"+t,t+=1,n.setAttribute("data-vscode-context",JSON.stringify({webviewSection:"image",id:n.id,preventDefaultContextMenuItems:!0,resource:j}))}async function De(e,t=5){if(!document.hasFocus()&&t>0){setTimeout(()=>{De(e,t-1)},20);return}try{await navigator.clipboard.write([new ClipboardItem({"image/png":new Promise(n=>{let r=document.createElement("canvas");r!==null&&(r.width=e.naturalWidth,r.height=e.naturalHeight,r.getContext("2d")?.drawImage(e,0,0)),r.toBlob(i=>{i&&n(i),r.remove()},"image/png")})})])}catch(n){console.error(n)}}window.addEventListener("message",async e=>{let t=e.data;switch(t.type){case"copyImage":{let n=document.getElementById(t.id);n instanceof HTMLImageElement&&De(n);return}case"onDidChangeTextEditorSelection":t.source===j&&Pe.onDidChangeTextEditorSelection(t.line,M);return;case"updateView":t.source===j&&pt(t.line);return;case"updateContent":{let n=document.querySelector(".markdown-body"),i=new DOMParser().parseFromString(t.content,"text/html");for(let a of Array.from(i.querySelectorAll("meta")))a.hasAttribute("http-equiv")&&a.remove();if(t.source!==j)n.replaceWith(i.querySelector(".markdown-body")),j=t.source;else{let a=["open"],s=(d,p)=>{if(d.isEqualNode(p))return!0;if(d.tagName!==p.tagName||d.textContent!==p.textContent)return!1;let b=[...d.attributes].filter(g=>!a.includes(g.name)),T=[...p.attributes].filter(g=>!a.includes(g.name));if(b.length!==T.length)return!1;for(let g=0;g<b.length;++g){let S=b[g],L=T[g];if(S.name!==L.name||S.value!==L.value&&S.name!=="data-line")return!1}let E=Array.from(d.children),N=Array.from(p.children);return E.length===N.length&&E.every((g,S)=>s(g,N[S]))},u=i.querySelector(".markdown-body"),m=u.querySelectorAll("link");for(let d of m)d.remove();u.prepend(...m),Se(n,u,{childrenOnly:!0,onBeforeElUpdated:(d,p)=>{if(s(d,p)){let b=d.querySelectorAll("[data-line]"),T=p.querySelectorAll("[data-line]");b.length!==T.length&&console.log("unexpected line number change");for(let E=0;E<b.length;++E){let N=b[E],g=T[E];g&&N.setAttribute("data-line",g.getAttribute("data-line"))}return!1}return d.tagName==="DETAILS"&&p.tagName==="DETAILS"&&d.hasAttribute("open")&&p.setAttribute("open",""),!0}})}++M,window.dispatchEvent(new CustomEvent("vscode.markdown.updateContent")),Oe();break}}},!1);document.addEventListener("dblclick",e=>{if(!y.settings.doubleClickToSwitchToEditor)return;for(let r=e.target;r;r=r.parentNode)if(r.tagName==="A")return;let t=e.pageY,n=se(t,M);typeof n=="number"&&!isNaN(n)&&X.postMessage("didClick",{line:Math.floor(n)})});var vt=["http:","https:","mailto:","vscode:","vscode-insiders:"];document.addEventListener("click",e=>{if(!e)return;let t=e.target;for(;t;){if(t.tagName&&t.tagName==="A"&&t.href){if(t.getAttribute("href").startsWith("#"))return;let n=t.getAttribute("data-href");if(!n){if(vt.some(r=>t.href.startsWith(r)))return;n=t.getAttribute("href")}if(!/^[a-z\-]+:/i.test(n)){X.postMessage("openLink",{href:n}),e.preventDefault(),e.stopPropagation();return}return}t=t.parentNode}},!0);window.addEventListener("scroll",Ce(()=>{if(Ie(),H>0)H-=1;else{let e=se(window.scrollY,M);typeof e=="number"&&!isNaN(e)&&X.postMessage("revealLine",{line:e})}},50));function Ie(){C.scrollProgress=window.scrollY/document.body.clientHeight,q.setState(C)}
</script>

    </body>
</html>
