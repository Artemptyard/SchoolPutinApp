from django.shortcuts import render
from django.core.handlers.wsgi import WSGIRequest
from django.shortcuts import get_object_or_404
from django.contrib.auth.mixins import UserPassesTestMixin

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import generics as rfg
from rest_framework.permissions import IsAuthenticated, BasePermission, SAFE_METHODS

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from .models import User, Student, Parent, Teacher
from schedule.models import Group, Subject
from .serializer import UserSerializer, StudentSerializer, ParentSerializer, TeacherSerializer
from schedule.serializers import SubjectSerializer


class StudentList(rfg.ListAPIView):
    """Получение списка всех студентов преподавателя"""
    # queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        teacher = Teacher.objects.get(user=self.request.user)
        subjects = teacher.subjects.all()
        groups = Group.objects.filter(subject__in=subjects).distinct()
        return Student.objects.filter(groups__in=groups).distinct()


class IsAdminUser(BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_superuser


class UserCreator(rfg.CreateAPIView):
    """Создание пользователя

    Создаётся запись в таблицах User и таблице, согласно указанной роли.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def test_func(self):
        return self.request.user.is_superuser


class UserManager(rfg.RetrieveUpdateDestroyAPIView):
    """Получение, изменение и удаление пользователя"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class StudentCreater(rfg.CreateAPIView):
    """Создание студента

    Создаётся запись в таблицах User и Student.
    """
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class IsAdminOrSelf(BasePermission):
    """Доступ разрешён, если пользователь — админ или он сам запрашивает свои данные"""
    def has_object_permission(self, request, view, obj):
        user = request.user
        if not user.is_authenticated:
            return False
        if user.is_superuser:
            return True

        # Проверка по связанному пользователю
        if hasattr(obj, 'user'):
            return obj.user == user

        # Альтернатива: если Student/Teacher/Parent == user напрямую
        return obj == user


class StudentManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление студента"""
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [IsAdminOrSelf]


class ParentManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление родителя"""
    queryset = Parent.objects.all()
    serializer_class = ParentSerializer
    permission_classes = [IsAdminOrSelf]


class TeacherManager(rfg.RetrieveUpdateAPIView):
    """Получение, изменение и удаление учителя"""
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer
    permission_classes = [IsAdminOrSelf]


class KinshipManager(APIView):
    """Управление связью между родителем и ребёнком"""
    permission_classes = [IsAdminUser]

    @swagger_auto_schema(request_body=None, responses={201: ParentSerializer})
    def post(self, request: WSGIRequest, student_id: int, parent_id: int, format=None):
        """Добавление связи между родителем и ребёнком"""
        student: Student = get_object_or_404(Student, id=student_id)
        parent: Parent = get_object_or_404(Parent, id=parent_id)
        parent.students.add(student)
        parent.save()
        return Response(ParentSerializer(parent).data, status=status.HTTP_201_CREATED)

    @swagger_auto_schema(request_body=None, responses={200: ParentSerializer})
    def delete(self, request: WSGIRequest, student_id: int, parent_id: int, format=None):
        """Удаление связи между родителем и ребёнком"""
        student: Student = get_object_or_404(Student, id=student_id)
        parent: Parent = get_object_or_404(Parent, id=parent_id)
        parent.students.remove(student)
        parent.save()
        return Response(ParentSerializer(parent).data, status=status.HTTP_200_OK)


@swagger_auto_schema(method='get', request_body=None, responses={200: StudentSerializer(many=True)})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_children(request: WSGIRequest, parent_id: int):
    """Получение детей родителя"""
    parent = get_object_or_404(Parent, id=parent_id)
    students = parent.students.all()
    return Response(StudentSerializer(students, many=True).data, status=status.HTTP_200_OK)


@swagger_auto_schema(method='get', request_body=None, responses={200: ParentSerializer(many=True)})
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_parents(request: WSGIRequest, student_id: int):
    """Получение родителей ребёнка"""
    student = get_object_or_404(Student, id=student_id)
    parents = student.parents.all()
    return Response(ParentSerializer(parents, many=True).data, status=status.HTTP_200_OK)


class SubjectsManager(APIView):
    """Управление связью между преподавателем и его предметами"""
    permission_classes = [IsAdminUser]

    @swagger_auto_schema(request_body=None, responses={201: TeacherSerializer})
    def post(self, request: WSGIRequest, teacher_id: int, subject_id: int, format=None):
        """Добавление предмета преподавателю"""
        teacher: Teacher = get_object_or_404(Teacher, id=teacher_id)
        subject: Subject = get_object_or_404(Subject, id=subject_id)
        teacher.subjects.add(subject)
        teacher.save()
        return Response(TeacherSerializer(teacher).data, status=status.HTTP_201_CREATED)

    @swagger_auto_schema(request_body=None, responses={200: TeacherSerializer})
    def delete(self, request: WSGIRequest, student_id: int, parent_id: int, format=None):
        """Удаление предмета у преподавателя"""
        teacher: Teacher = get_object_or_404(Teacher, id=teacher_id)
        subject: Subject = get_object_or_404(Subject, id=subject_id)
        teacher.subjects.remove(subject)
        teacher.save()
        return Response(TeacherSerializer(teacher).data, status=status.HTTP_201_CREATED)