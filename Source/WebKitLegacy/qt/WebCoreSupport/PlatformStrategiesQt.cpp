/*
 * Copyright (C) 2007 Staikos Computing Services Inc. <info@staikos.net>
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2008 Collabora Ltd. All rights reserved.
 * Copyright (C) 2010 Apple Inc. All rights reserved.
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
#include "PlatformStrategiesQt.h"

#include "Chrome.h"
#include "ChromeClientQt.h"
#include "QWebPageAdapter.h"
#include "qwebhistoryinterface.h"
#include "WebResourceLoadScheduler.h"

#include <BlobRegistryImpl.h>
#include <IntSize.h>
#include <NetworkStorageSession.h>
#include <NotImplemented.h>
#include <Page.h>
#include <PageGroup.h>
#include <PlatformCookieJar.h>
#include <QCoreApplication>
#include <QLocale>
#include <wtf/MathExtras.h>
#include <wtf/NeverDestroyed.h>

using namespace WebCore;

void PlatformStrategiesQt::initialize()
{
    static NeverDestroyed<PlatformStrategiesQt> platformStrategies;
    Q_UNUSED(platformStrategies);
}

PlatformStrategiesQt::PlatformStrategiesQt()
{
    setPlatformStrategies(this);
}


CookiesStrategy* PlatformStrategiesQt::createCookiesStrategy()
{
    return this;
}

LoaderStrategy* PlatformStrategiesQt::createLoaderStrategy()
{
    return new WebResourceLoadScheduler;
}

PasteboardStrategy* PlatformStrategiesQt::createPasteboardStrategy()
{
    return 0;
}

std::pair<String, bool> PlatformStrategiesQt::cookiesForDOM(const WebCore::NetworkStorageSession& session, const WebCore::URL& firstParty, const WebCore::URL& url, std::optional<uint64_t> frameID, std::optional<uint64_t> pageID, WebCore::IncludeSecureCookies includeSecureCookies)
{
    return WebCore::cookiesForDOM(session, firstParty, url, frameID, pageID, includeSecureCookies);
}

void PlatformStrategiesQt::setCookiesFromDOM(const NetworkStorageSession& session, const URL& firstParty, const URL& url, std::optional<uint64_t> frameID, std::optional<uint64_t> pageID, const String& cookieString)
{
    WebCore::setCookiesFromDOM(session, firstParty, url, frameID, pageID, cookieString);
}

bool PlatformStrategiesQt::cookiesEnabled(const NetworkStorageSession& session)
{
    return WebCore::cookiesEnabled(session);
}

std::pair<String, bool> PlatformStrategiesQt::cookieRequestHeaderFieldValue(const NetworkStorageSession& session, const URL& firstParty, const URL& url, std::optional<uint64_t> frameID, std::optional<uint64_t> pageID, WebCore::IncludeSecureCookies includeSecureCookies)
{
    return WebCore::cookieRequestHeaderFieldValue(session, firstParty, url, frameID, pageID, includeSecureCookies);
}

std::pair<String, bool> PlatformStrategiesQt::cookieRequestHeaderFieldValue(PAL::SessionID sessionID, const URL& firstParty, const URL& url, std::optional<uint64_t> frameID, std::optional<uint64_t> pageID, WebCore::IncludeSecureCookies includeSecureCookies)
{
    // FIXME: okay to always use default?
    auto& session = NetworkStorageSession::defaultStorageSession();
    return WebCore::cookieRequestHeaderFieldValue(session, firstParty, url, frameID, pageID, includeSecureCookies);
}

bool PlatformStrategiesQt::getRawCookies(const NetworkStorageSession& session, const URL& firstParty, const URL& url, std::optional<uint64_t> frameID, std::optional<uint64_t> pageID, Vector<Cookie>& rawCookies)
{
    return WebCore::getRawCookies(session, firstParty, url, frameID, pageID, rawCookies);
}

void PlatformStrategiesQt::deleteCookie(const NetworkStorageSession& session, const URL& url, const String& cookieName)
{
    WebCore::deleteCookie(session, url, cookieName);
}

BlobRegistry* PlatformStrategiesQt::createBlobRegistry()
{
    return new BlobRegistryImpl;
}
