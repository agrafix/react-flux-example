window['React'] = require('react');
window['ReactDOM'] = require('react-dom');
var ri = require('react-intl');
window['ReactIntl'] = ri;

ri.addLocaleData([
    require('react-intl/locale-data/en').en,
    require('react-intl/locale-data/de').de,
    require('react-intl/locale-data/fr').fr
]);

window['config'] = {
    locale: 'en'
};

var reactChart = require('react-chartjs');
window['ReactChartLine'] = reactChart.Line;

var reactLeaflet = require('react-leaflet');
window['Leaflet.Map'] = reactLeaflet.Map;
window['Leaflet.TileLayer'] = reactLeaflet.TileLayer;
window['Leaflet.Marker'] = reactLeaflet.Marker;
window['Leaflet.Popup'] = reactLeaflet.Popup;
