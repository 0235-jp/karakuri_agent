# Copyright (c) 0235 Inc.
# This file is licensed under the karakuri_agent Personal Use & No Warranty License.
# Please see the LICENSE file in the project root.
from pydantic import BaseModel

class LLMResponse(BaseModel):
    user_message: str
    agent_message: str
    emotion: str
