from django.shortcuts import render
from rest_framework import viewsets
from .models import Schedule, Group, Subject
from .serializers import ScheduleSerializer, GroupSerializer, SubjectSerializer


# Create your views here.
class ScheduleViewSet(viewsets.ModelViewSet):
    queryset = Schedule.objects.all()
    serializer_class = ScheduleSerializer


class GroupViewSet(viewsets.ModelViewSet):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer


class SubjectViewSet(viewsets.ModelViewSet):
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer
