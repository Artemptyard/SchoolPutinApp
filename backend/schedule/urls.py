from rest_framework.routers import DefaultRouter
from .views import ScheduleViewSet, GroupViewSet, SubjectViewSet

router = DefaultRouter()
router.register(r'schedules', ScheduleViewSet)
router.register(r"groups", GroupViewSet)
router.register(r"subjects", SubjectViewSet)

urlpatterns = router.urls