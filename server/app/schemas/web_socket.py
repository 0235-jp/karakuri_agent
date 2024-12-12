# Copyright (c) 0235 Inc.
# This file is licensed under the karakuri_agent Personal Use & No Warranty License.
# Please see the LICENSE file in the project root.
from pydantic import BaseModel
from typing import Literal

class BaseRequest(BaseModel):
    request_type: str
    responce_type: str
    agent_id: str

class TextRequest(BaseRequest):
    request_type: Literal["text"] = "text"
    text: str

class AudioRequest(BaseRequest):
    request_type: Literal["audio"] = "audio"
    audio: str

class BaseResponse(BaseModel):
    responce_type: str

class TextResponse(BaseResponse):
    responce_type: Literal["text"] = "text"
    user_message: str
    agent_message: str
    emotion: str

class AudioResponse(TextResponse):
    responce_type: Literal["audio"] = "audio"
    audio_url: str
    duration: int
