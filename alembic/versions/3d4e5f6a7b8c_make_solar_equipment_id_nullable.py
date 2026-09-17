"""make solar_units columns nullable for asset separation

Revision ID: 3d4e5f6a7b8c
Revises: 26aac93af61f
Create Date: 2026-09-13 10:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '3d4e5f6a7b8c'
down_revision: Union[str, Sequence[str], None] = '26aac93af61f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema: Allow solar_units IDs to be NULL for independent asset stock."""
    op.alter_column('solar_units', 'shs_machine_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=True)
    op.alter_column('solar_units', 'solar_equipment_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=True)
    op.alter_column('solar_units', 'radio_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=True)
    op.alter_column('solar_units', 'flashlight_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=True)
    op.alter_column('solar_units', 'led_light_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=True)


def downgrade() -> None:
    """Downgrade schema."""
    op.alter_column('solar_units', 'led_light_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=False)
    op.alter_column('solar_units', 'flashlight_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=False)
    op.alter_column('solar_units', 'radio_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=False)
    op.alter_column('solar_units', 'solar_equipment_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=False)
    op.alter_column('solar_units', 'shs_machine_id',
               existing_type=sa.VARCHAR(length=100),
               nullable=False)
