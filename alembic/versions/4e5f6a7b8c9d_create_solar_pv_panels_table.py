"""create solar_pv_panels table for decoupled PV asset lifecycle management

Revision ID: 4e5f6a7b8c9d
Revises: 3d4e5f6a7b8c
Create Date: 2026-09-13 14:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '4e5f6a7b8c9d'
down_revision: Union[str, Sequence[str], None] = '3d4e5f6a7b8c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema: Create independent solar_pv_panels table."""
    op.create_table(
        'solar_pv_panels',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('pv_sn', sa.String(length=100), nullable=False),
        sa.Column('status', sa.Integer(), nullable=True, server_default='0'),
        sa.Column('shs_machine_id', sa.String(length=100), nullable=True),
        sa.Column('customer_uuid', sa.String(length=100), nullable=True),
        sa.Column('customer_name', sa.String(length=100), nullable=True),
        sa.Column('city', sa.String(length=100), nullable=True),
        sa.Column('town', sa.String(length=100), nullable=True),
        sa.Column('production_date', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('now()')),
        sa.Column('bound_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.text('now()'))
    )
    op.create_index(op.f('ix_solar_pv_panels_id'), 'solar_pv_panels', ['id'], unique=False)
    op.create_index(op.f('ix_solar_pv_panels_pv_sn'), 'solar_pv_panels', ['pv_sn'], unique=True)
    op.create_index(op.f('ix_solar_pv_panels_status'), 'solar_pv_panels', ['status'], unique=False)
    op.create_index(op.f('ix_solar_pv_panels_shs_machine_id'), 'solar_pv_panels', ['shs_machine_id'], unique=False)
    op.create_index(op.f('ix_solar_pv_panels_customer_uuid'), 'solar_pv_panels', ['customer_uuid'], unique=False)


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index(op.f('ix_solar_pv_panels_customer_uuid'), table_name='solar_pv_panels')
    op.drop_index(op.f('ix_solar_pv_panels_shs_machine_id'), table_name='solar_pv_panels')
    op.drop_index(op.f('ix_solar_pv_panels_status'), table_name='solar_pv_panels')
    op.drop_index(op.f('ix_solar_pv_panels_pv_sn'), table_name='solar_pv_panels')
    op.drop_index(op.f('ix_solar_pv_panels_id'), table_name='solar_pv_panels')
    op.drop_table('solar_pv_panels')
