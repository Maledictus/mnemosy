﻿/*
The MIT License(MIT)

Copyright (c) 2016-2018 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "utils.h"

#include <tuple>

#include <QList>
#include <QRegularExpression>
#include <QtDebug>

namespace Mnemosy
{
namespace Utils
{
void SetImagesWidth(QString& text, bool& hasArg)
{
    QRegularExpression imgRxp("\\<img.*?src\\s*=\\s*('|\")(.+?)('|\").*?\\>",
            QRegularExpression::CaseInsensitiveOption);
    QList<QPair<QString, QString>> matched;
    QRegularExpressionMatchIterator matchIt = imgRxp.globalMatch(text);
    while (matchIt.hasNext())
    {
        QRegularExpressionMatch match = matchIt.next();
        const auto& imgTag = match.captured(0);
        if (!imgTag.contains("l-stat.livejournal.net") &&
                !imgTag.contains("l-files.livejournal.net") &&
                !imgTag.contains("www.livejournal.com/img/userinfo"))
        {
            matched << QPair<QString, QString>(imgTag, match.captured(2));
        }
    }

    for (const auto& t : matched)
    {
        text.replace (t.first,
                "<img src=\"" + t.second + QString("\" width=\"%1\" >"));
        if (!hasArg)
        {
            hasArg = true;
        }
    }
}

void MoveFirstImageToTheTop(QString& text)
{
    QRegularExpression imgRxp("(\\<img[\\w\\W]+?\\/?\\>)",
            QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = imgRxp.match(text);
    if (match.hasMatch())
    {
        QString matched = match.captured(0);
        text.remove(match.capturedStart(0), match.capturedLength(0));
        text.push_front(matched);
    }
}

void RemoveStyleTag(QString& text)
{
    QRegularExpression styleRxp ("style=\"(.+?)\"",
            QRegularExpression::CaseInsensitiveOption);
    text.remove(styleRxp);
}

void FixUntaggedUrls(QString& text)
{
    auto pattern = "(?<!=\"|='|:\\/\\/)((http:\\/\\/|ftp:\\/\\/|https:\\/\\/|www\\.)([\\w\u0410-\u044f_-]+(?:(?:\\.[\\w\u0410-\u044f_-]+)+))([\\w\u0410-\u044f.,@?^=%&:\\/~+#-]*[\\w\u0410-\u044f@?^=%&\\/~+#-])?)";
    QRegularExpression untaggedUrlRxp(pattern, QRegularExpression::CaseInsensitiveOption);
    text.replace(untaggedUrlRxp, "<a href=\"\\1\">\\1</a>");
}

void TryToFillEventFields(LJEvent& event)
{
    if (!event.GetPosterID() && !event.GetPosterPicUrl().isEmpty())
    {
        QString url = event.GetPosterPicUrl().toString();
        event.SetPosterID(url.mid(url.lastIndexOf("/") + 1)
                .toLongLong());
    }

    if (event.GetPosterName().isEmpty())
    {
        QString url = event.GetUrl().toString();
        QString name = url.mid(7, url.indexOf(".") - 7);
        name.replace('-', "_");
        event.SetPosterName(name);
    }
}

QString AccessToString(Access acc)
{
    switch (acc)
    {
    case APrivate:
        return "private";
    case APublic:
        return "public";
    case ACustom:
    default:
        return "usemask";
    }
}

QString AdultContentToString(AdultContent ac)
{
    switch (ac)
    {
    case ACAdultsFrom14:
        return "concepts";
    case ACAdultsFrom18:
        return "explicit";
    case ACWithoutAdultContent:
    default:
        return "none";
    }
}

QString ScreeningToString(CommentsManagement cm)
{
    switch (cm)
    {
    case CMShowFriendsComments:
        return "F";
    case CMScreenComments:
        return "A";
    case CMScreenAnonymouseComments:
        return "R";
    case CMScreenNotFromFriendsWithLinks:
        return "L";
    case CMShowComments:
    default:
        return "N";
    }
}

void ReplaceLJTagsWithHTML(QString& text)
{
    auto pattern = "\\<lj.*?user=(\"|')(\\w+)('|\").*?userhead_url=(\"|')(.*?)('|\").*?\\>.*?<\\/lj\\>";
    QRegularExpression ljUserRxp(pattern, QRegularExpression::CaseInsensitiveOption);
    text.replace(ljUserRxp, "<a href=\"https://\\2.livejournal.com/\">\\2</a>");
}

}
} // namespace Mnemosy

