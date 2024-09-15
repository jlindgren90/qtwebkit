/*
 * Copyright (C) 2007 Staikos Computing Services Inc. <info@staikos.net>
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2008 Collabora Ltd. All rights reserved.
 * Copyright (C) 2010, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2010 INdT - Instituto Nokia de Tecnologia
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"
#include "LocalizedStrings.h"

#include "IntSize.h"
#include "NotImplemented.h"
#include <QCoreApplication>
#include <wtf/MathExtras.h>
#include <wtf/text/WTFString.h>

namespace WebCore {

String contextMenuItemTagOpenLinkInThisWindow()
{
    return QCoreApplication::translate("QWebPage", "Open in This Window", "Open in This Window context menu item");
}

String contextMenuItemTagCopyImageUrlToClipboard()
{
    return QCoreApplication::translate("QWebPage", "Copy Image Address", "Copy Image Address menu item");
}

String contextMenuItemTagDownloadMediaToDisk()
{
    return QCoreApplication::translate("QWebPage", "Download Media", "Download Media context menu item");
}

String contextMenuItemTagCopyMediaLinkToClipboard()
{
    return QCoreApplication::translate("QWebPage", "Copy Media Address", "Copy Media Link to Clipboard");
}

String contextMenuItemTagSelectAll()
{
    return QCoreApplication::translate("QWebPage", "Select All", "Select All context menu item");
}

String contextMenuItemTagSearchWeb()
{
    return QCoreApplication::translate("QWebPage", "Search The Web", "Search The Web context menu item");
}

String unacceptableTLSCertificate()
{
    notImplemented();
    return String();
}

String localizedString(const char* key)
{
    return String::fromUTF8(key, strlen(key));
}

}
