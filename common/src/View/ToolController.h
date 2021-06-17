/*
 Copyright (C) 2010-2017 Kristian Duske

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

#include "FloatType.h"
#include "ToolChain.h"
#include "Model/HitFilter.h"
#include "Model/HitType.h"
#include "View/InputState.h"

#include <vecmath/vec.h>
#include <vecmath/line.h>
#include <vecmath/plane.h>

#include <memory>
#include <string>
#include <vector>

namespace TrenchBroom {
    namespace Model {
        class Hit;
        class HitQuery;
        class PickResult;
    }

    namespace Renderer {
        class RenderBatch;
        class RenderContext;
    }

    namespace View {
        class DragTracker;
        class DropTracker;
        class InputState;
        class Tool;

        class ToolController {
        public:
            virtual ~ToolController();

            Tool* tool();
            const Tool* tool() const;
            bool toolActive() const;

            virtual void pick(const InputState& inputState, Model::PickResult& pickResult);

            virtual void modifierKeyChange(const InputState& inputState);

            virtual void mouseDown(const InputState& inputState);
            virtual void mouseUp(const InputState& inputState);
            virtual bool mouseClick(const InputState& inputState);
            virtual bool mouseDoubleClick(const InputState& inputState);
            virtual void mouseMove(const InputState& inputState);
            virtual void mouseScroll(const InputState& inputState);

            virtual std::unique_ptr<DragTracker> acceptMouseDrag(const InputState& inputState);
            virtual bool anyToolDragging(const InputState& inputState) const;

            virtual std::unique_ptr<DropTracker> acceptDrop(const InputState& inputState, const std::string& payload);

            virtual void setRenderOptions(const InputState& inputState, Renderer::RenderContext& renderContext) const;
            virtual void render(const InputState& inputState, Renderer::RenderContext& renderContext, Renderer::RenderBatch& renderBatch);

            virtual bool cancel();
        protected:
            void refreshViews();
        private:
            virtual Tool* doGetTool() = 0;
            virtual const Tool* doGetTool() const = 0;
        };

        class ToolControllerGroup : public ToolController {
        private:
            ToolChain m_chain;
        public:
            ToolControllerGroup();
            ~ToolControllerGroup() override;
        protected:
            void addController(std::unique_ptr<ToolController> controller);
        public:
            void pick(const InputState& inputState, Model::PickResult& pickResult) override;

            void modifierKeyChange(const InputState& inputState) override;

            void mouseDown(const InputState& inputState) override;
            void mouseUp(const InputState& inputState) override;
            bool mouseClick(const InputState& inputState) override;
            bool mouseDoubleClick(const InputState& inputState) override;
            void mouseMove(const InputState& inputState) override;
            void mouseScroll(const InputState& inputState) override;

            std::unique_ptr<DragTracker> acceptMouseDrag(const InputState& inputState) override;
            std::unique_ptr<DropTracker> acceptDrop(const InputState& inputState, const std::string& payload) override;

            void setRenderOptions(const InputState& inputState, Renderer::RenderContext& renderContext) const override;
            void render(const InputState& inputState, Renderer::RenderContext& renderContext, Renderer::RenderBatch& renderBatch) override;

            bool cancel() override;
        private: // subclassing interface
            virtual bool doShouldHandleMouseDrag(const InputState& inputState) const;
            virtual bool doShouldHandleDrop(const InputState& inputState, const std::string& payload) const;
        };
    }
}

