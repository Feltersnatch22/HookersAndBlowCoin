// Copyright (c) 2011-2016 The Bitcoin Core developers
// Copyright (c) 2017-2021 The HookersAndBlow Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef RAVEN_QT_GUICONSTANTS_H
#define RAVEN_QT_GUICONSTANTS_H

/* Milliseconds between model updates */
static const int MODEL_UPDATE_DELAY = 250;

/* AskPassphraseDialog -- Maximum passphrase length */
static const int MAX_PASSPHRASE_SIZE = 1024;

/* HookersAndBlowGUI -- Size of icons in status bar */
static const int STATUSBAR_ICONSIZE = 16;

static const bool DEFAULT_SPLASHSCREEN = true;

/* Invalid field background style */
#define STYLE_INVALID "background:#FF8080; border: 1px solid lightgray; padding: 0px;"
#define STYLE_VALID "border: 1px solid lightgray; padding: 0px;"

/* Transaction list -- unconfirmed transaction */
#define COLOR_UNCONFIRMED QColor(128, 128, 128)
/* Transaction list -- negative amount */
#define COLOR_NEGATIVE QColor(255, 0, 0)
/* Transaction list -- bare address (without label) */
#define COLOR_BAREADDRESS QColor(140, 140, 140)
/* Transaction list -- TX status decoration - open until date */
#define COLOR_TX_STATUS_OPENUNTILDATE QColor(255, 20, 147)
/* Transaction list -- TX status decoration - danger, tx needs attention */
#define COLOR_TX_STATUS_DANGER QColor(200, 100, 100)
/* Transaction list -- TX status decoration - default color */
#define COLOR_BLACK QColor(10, 10, 10)
/* Widget Background color - default color */
#define COLOR_WHITE QColor(255, 255, 255)

#define COLOR_WALLETFRAME_SHADOW QColor(0,0,0,71)

/* HNB brand: black, grey, pink */
#define COLOR_HNB_PINK QColor("#FF1493")
#define COLOR_HNB_PINK_LIGHT QColor("#FF69B4")
#define COLOR_HNB_GREY_DARK QColor("#2a2a2a")
#define COLOR_HNB_GREY_MID QColor("#6b6b6b")
#define COLOR_HNB_GREY_LIGHT QColor("#e8e8e8")

/* Color of labels */
#define COLOR_LABELS COLOR_HNB_GREY_MID

/** LIGHT MODE */
/* Background color, light grey */
#define COLOR_BACKGROUND_LIGHT QColor("#f0f0f0")
/* Accent pink (reuses legacy orange slot) */
#define COLOR_DARK_ORANGE COLOR_HNB_PINK
/* Lighter pink accent */
#define COLOR_LIGHT_ORANGE COLOR_HNB_PINK_LIGHT
/* Dark grey panels */
#define COLOR_DARK_BLUE COLOR_HNB_GREY_DARK
/* Mid grey panels */
#define COLOR_LIGHT_BLUE QColor("#4a4a4a")
/* Asset card text */
#define COLOR_ASSET_TEXT QColor(255, 255, 255)
/* Shadow - light mode */
#define COLOR_SHADOW_LIGHT QColor("#d0d0d0")
/* Toolbar not selected text color */
#define COLOR_TOOLBAR_NOT_SELECTED_TEXT QColor("#a0a0a0")
/* Toolbar selected text color */
#define COLOR_TOOLBAR_SELECTED_TEXT COLOR_WHITE
/* Send entries background color */
#define COLOR_SENDENTRIES_BACKGROUND COLOR_BACKGROUND_LIGHT


/** DARK MODE */
/* Widget background color, dark mode */
#define COLOR_WIDGET_BACKGROUND_DARK QColor("#1a1a1a")
/* Shadow - dark mode (near black) */
#define COLOR_SHADOW_DARK QColor("#0a0a0a")
/* Mid grey - dark mode */
#define COLOR_LIGHT_BLUE_DARK QColor("#2a2a2a")
/* Black panels - dark mode */
#define COLOR_DARK_BLUE_DARK QColor("#0a0a0a")
/* Header bar background */
#define COLOR_PRICING_WIDGET QColor("#141414")
/* Administrator asset cards */
#define COLOR_ADMIN_CARD_DARK COLOR_HNB_PINK
/* Regular asset cards - dark mode */
#define COLOR_REGULAR_CARD_DARK_BLUE_DARK_MODE QColor("#1a1a1a")
#define COLOR_REGULAR_CARD_LIGHT_BLUE_DARK_MODE QColor("#2a2a2a")
/* Toolbar not selected text color */
#define COLOR_TOOLBAR_NOT_SELECTED_TEXT_DARK_MODE QColor("#888888")
/* Toolbar selected text color */
#define COLOR_TOOLBAR_SELECTED_TEXT_DARK_MODE COLOR_HNB_PINK
/* Send entries background color dark mode */
#define COLOR_SENDENTRIES_BACKGROUND_DARK QColor("#1a1a1a")


/* Label color as a string */
#define STRING_LABEL_COLOR "color: #6b6b6b"
#define STRING_LABEL_COLOR_WARNING "color: #FF8080"
#define STRING_LABEL_COLOR_ACCENT "color: #FF1493"

/* Tooltips longer than this (in characters) are converted into rich text,
   so that they can be word-wrapped.
 */
static const int TOOLTIP_WRAP_THRESHOLD = 80;

/* Maximum allowed URI length */
static const int MAX_URI_LENGTH = 255;

/* QRCodeDialog -- size of exported QR Code image */
#define QR_IMAGE_SIZE 300

/* Number of frames in spinner animation */
#define SPINNER_FRAMES 36

#define QAPP_ORG_NAME "HookersAndBlow"
#define QAPP_ORG_DOMAIN "hookersandblow.org"
#define QAPP_APP_NAME_DEFAULT "HookersAndBlow-Qt"
#define QAPP_APP_NAME_TESTNET "HookersAndBlow-Qt-testnet"

/* Default third party browser urls */
#define DEFAULT_THIRD_PARTY_BROWSERS ""

/* Default IPFS viewer */
#define DEFAULT_IPFS_VIEWER "https://ipfs.io/ipfs/%s"

#endif // RAVEN_QT_GUICONSTANTS_H
