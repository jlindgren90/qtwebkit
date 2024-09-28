/*
    Copyright (C) 2007 Staikos Computing Services Inc.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "config.h"
#include "UndoStepQt.h"

#include <qobject.h>

using namespace WebCore;

UndoStepQt::UndoStepQt(UndoStep& step)
    : m_step(step)
    , m_first(true)
{
    m_text = undoRedoLabel(step.editingAction());
}

UndoStepQt::~UndoStepQt()
{
}

void UndoStepQt::redo()
{
    if (m_first) {
        m_first = false;
        return;
    }
    m_step->reapply();
}


void UndoStepQt::undo()
{
    m_step->unapply();
}

QString UndoStepQt::text() const
{
    return m_text;
}

// vim: ts=4 sw=4 et
