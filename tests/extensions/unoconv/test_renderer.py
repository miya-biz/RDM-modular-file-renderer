from unittest import mock

import pytest

from mfr.core.provider import ProviderMetadata
from mfr.extensions.unoconv import UnoconvRenderer, settings


@pytest.fixture
def metadata():
    return ProviderMetadata('test', '.docx', 'application/octet-stream', '1234', 'http://localhost:7777/test.docx')


@pytest.fixture
def renderer(metadata):
    return UnoconvRenderer(metadata, '/tmp/test.docx', 'http://localhost:7777/test.docx',
                           'http://mfr.example.com/assets', 'http://mfr.example.com/export?url=test.docx')


class TestUnoconvRenderer:

    def test_renders_through_pdf_by_default(self, renderer):
        assert renderer.map == settings.DEFAULT_RENDER
        assert renderer.export_file_path == '/tmp/test.docx.pdf'
        assert renderer.renderer.__class__.__name__ == 'PdfRenderer'

    def test_use_celery_defaults_to_in_request_rendering(self, renderer):
        assert settings.USE_CELERY is False
        assert renderer.use_celery is False

    def test_use_celery_follows_the_setting(self, renderer):
        with mock.patch.object(settings, 'USE_CELERY', True):
            assert renderer.use_celery is True
