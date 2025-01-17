/*
 Copyright (C) 2010-2017 Kristian Duske
 Copyright (C) 2022 Robert Beckebans

 This file is part of TrenchBroom.

 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with TrenchBroom. If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once

#include "Model/IssueGenerator.h"

#include <vector>

namespace TrenchBroom {
namespace Model {

// Doom 3 requires all brush based entities to have a "model" key which is the same as the "name"
// key
class BrushEntityWithoutModelKeyIssueGenerator : public IssueGenerator {
private:
  class BrushEntityWithoutModelKeyIssue;
  class BrushEntityWithoutModelKeyIssueQuickFix;

public:
  BrushEntityWithoutModelKeyIssueGenerator();

private:
  void doGenerate(EntityNode* entityNode, IssueList& issues) const override;
};
} // namespace Model
} // namespace TrenchBroom
