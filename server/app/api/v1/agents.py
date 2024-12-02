from fastapi import APIRouter, Depends, HTTPException
from app.auth.api_key import get_api_key
from app.core.agent_manager import get_agent_manager
from app.schemas.agent import AgentResponse
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/agents")
async def list_agents(api_key: str = Depends(get_api_key)):
    """
    登録されているエージェントの一覧を返します
    """
    try:
        agent_manager = get_agent_manager()
        agents = agent_manager.get_all_agents()
        return [
            AgentResponse(agent_id=id, agent_name=name)
            for id, name in agents
        ]
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching agents: {str(e)}"
        )