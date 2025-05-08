from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, Student, Teacher, Parent

@receiver(post_save, sender=User)
def create_profile_for_user(sender, instance, created, **kwargs):
    """Автоматическое создание таблицы в зависимости от роли"""
    if created:
        if instance.role == 'student':
            Student.objects.create(user=instance)
        elif instance.role == 'teacher':
            instance.is_staff = True
            instance.save()
            Teacher.objects.create(user=instance)
        elif instance.role == 'parent':
            Parent.objects.create(user=instance)
