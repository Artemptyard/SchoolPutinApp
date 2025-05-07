from rest_framework.routers import DefaultRouter
from .views import ScheduleViewSet, GroupViewSet, SubjectViewSet

router = DefaultRouter()
router.register(r'schedule', ScheduleViewSet)
router.register(r"group", GroupViewSet)
router.register(r"subject", SubjectViewSet)

urlpatterns = router.urls