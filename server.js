var soap = require('soap');
var url = 'http://soap.amazon.com/schemas2/AmazonWebServices.wsdl';
var args = {
	groupOrderID: 1,
	leagueShortcut: 'bl1',
	leagueSaison: '2010'
};
soap.createClient(url, function(err, client) {
	console.log(client.describe());
    client.ListManiaSearchRequest({matchID: 626}, function(err, result) {
        console.log(result);
    });
});