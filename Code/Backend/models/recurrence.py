from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class RecurrenceRule(Base):
    __tablename__ = 'recurrence_rules'

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey('events.id'), unique=True, nullable=False)
    frequency = Column(String, nullable=False, default='weekly')
    interval = Column(Integer, default=1)
    end_date = Column(DateTime)
    count = Column(Integer)

    event = relationship('Event', back_populates='recurrence')
    weekdays = relationship('RecurrenceWeekday', back_populates='rule', cascade='all, delete-orphan')

    @property
    def by_weekday(self):
        return sorted([weekday.weekday for weekday in self.weekdays])


class RecurrenceWeekday(Base):
    __tablename__ = 'recurrence_weekdays'

    id = Column(Integer, primary_key=True, index=True)
    rule_id = Column(Integer, ForeignKey('recurrence_rules.id'), nullable=False)
    weekday = Column(Integer, nullable=False)

    rule = relationship('RecurrenceRule', back_populates='weekdays')
