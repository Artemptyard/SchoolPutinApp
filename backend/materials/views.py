from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from .models import Material
from users.models import Student, Teacher
from .serializer import MaterialSerializer


# Create your views here.
class MaterialListView(generics.ListAPIView):
    """Получение доступных материалов

    Ученик просматривает материалы по своим предметам"""
    serializer_class = MaterialSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # if not hasattr(user, 'student'):
        #     raise PermissionDenied("Только ученики могут просматривать материалы.")
        student = user.student
        subjects = set()
        for group in student.groups.all():
            subjects.update(group.subjects.all())
        return Material.objects.filter(subject__in=subjects)


class MaterialCreateView(generics.CreateAPIView):
    """Добавление материала

    Добавлять может только преподаватель."""
    serializer_class = MaterialSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        user = self.request.user
        if not hasattr(user, 'teacher'):
            raise PermissionDenied("Только преподаватели могут загружать материалы.")
        serializer.save(teacher=user.teacher)


class MaterialUpdateView(generics.UpdateAPIView):
    """Изменение материала по его id

    Изменять может преподаватель и админ."""
    queryset = Material.objects.all()
    serializer_class = MaterialSerializer
    permission_classes = [IsAuthenticated]

    def perform_update(self, serializer):
        material = self.get_object()
        user = self.request.user
        if not (user.is_staff or getattr(user, 'teacher', None) == material.teacher):
            raise PermissionDenied("Вы не можете редактировать этот материал.")
        serializer.save()


class MaterialDeleteView(generics.DestroyAPIView):
    """Удаление материала по его id
    
    Удалять может преподаватель и админ."""
    queryset = Material.objects.all()
    serializer_class = MaterialSerializer
    permission_classes = [IsAuthenticated]

    def perform_destroy(self, instance):
        user = self.request.user
        if not (user.is_staff or getattr(user, 'teacher', None) == instance.teacher):
            raise PermissionDenied("Вы не можете удалить этот материал.")
        instance.delete()
