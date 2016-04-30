/**
 * @memberof $riffle
 * @function xsReplay
 * @param {RiffleDomain=} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Replay Replay} appliance. Defaults to the Replay appliance for the app.
 * @description Creates a new {@link Replay} class.
 * @returns {Replay} A new Replay object that can be used for interacting with a {@link /docs/appliances/Replay Replay} Appliance.
 * @example
 * //**Replay Example**
 *
 * //create a Replay instance from the proper Replay subdomain of your app
 * var replay = $riffle.xsReplay();
 *
 * //add a replay listener on the channel
 * replay.addReplay('xs.demo.dev.app.user/notifications').then(success, error);  
 *
 */

/**
 * @typedef Replay
 * @description The Replay class provides an API for interacting with an {@link /docs/appliances/Replay Replay} Appliance
 * @see {@link /docs/appliances/Replay here} for documentation.
 * @example
 * **Query a Replay Channel**
 * //create a Replay instance from the domain
 * var replay = $riffle.xsReplay();
 *
 * //get messages published to a channel between startts and stopts (seconds from epoch)
 * replay.getReplay('xs.demo.dev.app.user/messages', startts, stopts).then(handler, error);
 */
