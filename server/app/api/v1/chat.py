# Copyright (c) 0235 Inc.
# This file is licensed under the karakuri_agent Personal Use & No Warranty License.
# Please see the LICENSE file in the project root.
from fastapi import APIRouter, Depends, HTTPException, Response, UploadFile, File, Request
from app.dependencies import get_llm_service, get_tts_service, get_stt_service
from app.auth.api_key import get_api_key
from app.core.agent_manager import get_agent_manager
from app.utils.audio import calculate_audio_duration, upload_to_storage
import logging
import json
from starlette.responses import FileResponse
from pathlib import Path
from app.core.config import get_settings
from app.schemas.chat import TextChatRequest

router = APIRouter()
logger = logging.getLogger(__name__)
settings = get_settings()
UPLOAD_DIR = settings.chat_audio_files_dir
MAX_FILES = settings.chat_max_audio_files

@router.post("/text/text")
async def chat_text_to_text(
    request_body: TextChatRequest,
    api_key: str = Depends(get_api_key),
    llm_service = Depends(get_llm_service),
):
    agent_id = request_body.agent_id
    message = request_body.message

    agent_manager = get_agent_manager()
    agent_config = agent_manager.get_agent(agent_id)
    
    if not agent_config:
        raise HTTPException(
            status_code=404,
            detail=f"Agent ID {agent_id} not found"
        )
    try:
        llm_response = await llm_service.generate_response(
            "text_to_text",
            message, 
            agent_config
        )
        return Response(content=json.dumps(llm_response, ensure_ascii=False))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

@router.post("/text/voice")
async def chat_text_to_voice(
    request: Request,
    request_body: TextChatRequest,
    api_key: str = Depends(get_api_key),
    llm_service = Depends(get_llm_service),
    tts_service = Depends(get_tts_service)
):
    agent_id = request_body.agent_id
    message = request_body.message

    agent_manager = get_agent_manager()
    agent_config = agent_manager.get_agent(agent_id)
    
    if not agent_config:
        raise HTTPException(
            status_code=404,
            detail=f"Agent ID {agent_id} not found"
        )

    try:
        llm_response = await llm_service.generate_response(
            "text_to_voice",
            message, 
            agent_config
        )

        agent_message = llm_response["agent_message"].rstrip('\n')
        emotion = llm_response["emotion"]

        audio_data = await tts_service.generate_speech(
            agent_message, 
            agent_config
        )

        scheme = request.headers.get('X-Forwarded-Proto', 'http')
        server_host = request.headers.get('X-Forwarded-Host', request.base_url.hostname)
        base_url = f"{scheme}://{server_host}"
        
        audio_url = await upload_to_storage(base_url, audio_data, "chat", UPLOAD_DIR, MAX_FILES)
        duration = calculate_audio_duration(audio_data)
        return Response(content=json.dumps({
            "audio_url": audio_url,
            "duration": duration,
            "user_message": message,
            "agent_message": agent_message,
            "emotion": emotion,
        }, ensure_ascii=False))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

@router.post("/voice/text")
async def chat_voice_to_text(
    agent_id: str,
    audio_file: UploadFile = File(...),
    api_key: str = Depends(get_api_key),
    llm_service = Depends(get_llm_service),
    stt_service = Depends(get_stt_service)
):
    agent_manager = get_agent_manager()
    agent_config = agent_manager.get_agent(agent_id)
    
    if not agent_config:
        raise HTTPException(
            status_code=404,
            detail=f"Agent ID {agent_id} not found"
        )

    try:
        audio_content = await audio_file.read()
        
        text_message = await stt_service.transcribe_audio(
            audio_content,
            agent_config
        )

        llm_response = await llm_service.generate_response(
            "voice_to_text",
            text_message, 
            agent_config
        )

        return Response(content=json.dumps(llm_response, ensure_ascii=False))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

@router.post("/voice/voice")
async def chat_voice_to_voice(
    request: Request,
    agent_id: str,
    audio_file: UploadFile = File(...),
    api_key: str = Depends(get_api_key),
    llm_service = Depends(get_llm_service),
    stt_service = Depends(get_stt_service),
    tts_service = Depends(get_tts_service)
):
    agent_manager = get_agent_manager()
    agent_config = agent_manager.get_agent(agent_id)
    
    if not agent_config:
        raise HTTPException(
            status_code=404,
            detail=f"Agent ID {agent_id} not found"
        )

    try:
        audio_content = await audio_file.read()
        
        text_message = await stt_service.transcribe_audio(
            audio_content,
            agent_config
        )

        llm_response = await llm_service.generate_response(
            "voice_to_voice",
            text_message, 
            agent_config
        )
        agent_message = llm_response["agent_message"].rstrip('\n')
        emotion = llm_response["emotion"]

        audio_data = await tts_service.generate_speech(
            agent_message, 
            agent_config
        )


        scheme = request.headers.get('X-Forwarded-Proto', 'http')
        server_host = request.headers.get('X-Forwarded-Host', request.base_url.hostname)
        base_url = f"{scheme}://{server_host}"
        
        audio_url = await upload_to_storage(base_url, audio_data, "chat", UPLOAD_DIR, MAX_FILES)
        duration = calculate_audio_duration(audio_data)

        return Response(content=json.dumps({
            "audio_url": audio_url,
            "duration": duration,
            "user_message": text_message,
            "agent_message": agent_message,
            "emotion": emotion,
        }, ensure_ascii=False))
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error processing request: {str(e)}"
        )

@router.get(f"/{UPLOAD_DIR}/{{file_path}}")
async def get_audio(file_path: str):
    file_path = Path(f"{UPLOAD_DIR}/{file_path}.wav")
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Audio file not found")
    return FileResponse(file_path)
