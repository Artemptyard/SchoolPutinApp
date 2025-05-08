from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Gradebook
from users.models import Teacher, Student, Parent
from .serializer import GradebookSerializer
from rest_framework.exceptions import PermissionDenied


class TeacherGradeListView(generics.ListAPIView):
    """Получение списка оценок

    Оценки выставленны преподавателем в его группах."""
    serializer_class = GradebookSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            teacher = Teacher.objects.get(user=self.request.user)
        except Teacher.DoesNotExist:
            raise PermissionDenied("Вы не являетесь преподавателем.")
        subjects = teacher.subjects.all()
        return Gradebook.objects.filter(subject__in=subjects)


class StudentGradeListView(generics.ListAPIView):
    """Получение списка оценок

    Оценки студента по всем предметам."""
    serializer_class = GradebookSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            student = Student.objects.get(user=self.request.user)
        except Student.DoesNotExist:
            raise PermissionDenied("Вы не являетесь учеником.")
        return Gradebook.objects.filter(student=student)


class ParentGradeListView(generics.ListAPIView):
    """Получение списка оценок

    Все оценки детей родителя."""
    serializer_class = GradebookSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            parent = Parent.objects.get(user=self.request.user)
        except Parent.DoesNotExist:
            raise PermissionDenied("Вы не являетесь родителем.")
        return Gradebook.objects.filter(student__in=parent.items.all())


class GradeCreateView(generics.CreateAPIView):
    """Выставление оценок

    Выставлять может учитель и админ."""
    serializer_class = GradebookSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        if not (user.is_staff or hasattr(user, 'teacher')):
            raise PermissionDenied("Недостаточно прав для создания оценки.")
        serializer.save()


class GradeUpdateView(generics.UpdateAPIView):
    """Изменение оценок

    Изменять может учитель и админ."""
    queryset = Gradebook.objects.all()
    serializer_class = GradebookSerializer
    permission_classes = [IsAuthenticated]

    def perform_update(self, serializer):
        user = self.request.user
        if not (user.is_staff or hasattr(user, 'teacher')):
            raise PermissionDenied("Только преподаватели и администраторы могут изменять оценки.")
        serializer.save()